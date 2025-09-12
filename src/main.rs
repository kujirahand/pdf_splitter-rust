use lopdf::{dictionary, Document, Object, ObjectId};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::path::Path;

// 1つのPDFに含めるページ数
const DEFAULT_PAGE_COUNT: usize = 100;

#[derive(Serialize, Deserialize)]
struct Config {
    pages: usize,
}

/// 設定ファイルを読み込む関数
/// 1. 実行ファイルパス.json
/// 2. ~/.pdf_splitter.json
/// の順番で確認する
fn load_config() -> usize {
    // 実行ファイルのパスを取得
    if let Ok(exe_path) = env::current_exe() {
        let config_path = exe_path.with_extension("json");
        if let Ok(config) = load_config_file(&config_path) {
            return config.pages;
        }
    }
    
    // ホームディレクトリの設定ファイルを確認
    if let Ok(home) = env::var("HOME") {
        let config_path = Path::new(&home).join(".pdf_splitter.json");
        if let Ok(config) = load_config_file(&config_path) {
            return config.pages;
        }
    }
    
    // デフォルト値を返す
    DEFAULT_PAGE_COUNT
}

/// 指定されたパスから設定ファイルを読み込む
fn load_config_file(path: &Path) -> Result<Config, Box<dyn std::error::Error>> {
    let content = fs::read_to_string(path)?;
    let config: Config = serde_json::from_str(&content)?;
    Ok(config)
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("USAGES: pdf_splitter <file.pdf> <page_count>");
        return;
    }
    let input_path = &args[1];
    
    // 設定ファイルを読み込む
    let mut split_page_count = load_config();
    
    // コマンドライン引数でページ数が指定されていればそれを優先
    if args.len() >= 3 {
        if let Ok(count) = args[2].parse::<usize>() {
            split_page_count = count;
        }
    }
    
    if let Err(e) = split_pdf(input_path, split_page_count) {
        eprintln!("ERROR: {}", e);
    }
}

/// PDFを分割する関数
fn split_pdf(input_path: &str, split_page_count: usize) -> Result<(), Box<dyn std::error::Error>> {
    let doc = Document::load(input_path)?;
    let pages = doc.get_pages();
    let page_count = pages.len();
    let base_name = input_path.trim_end_matches(".pdf");
    
    // ファイル名部分のみを取得（パスからファイル名を分離）
    let filename_only = Path::new(base_name).file_name()
        .and_then(|name| name.to_str())
        .unwrap_or(base_name);
    
    // 出力フォルダを作成
    let output_dir = format!("{}-parts", base_name);
    fs::create_dir_all(&output_dir)?;

    for i in (0..page_count).step_by(split_page_count) {
        let mut new_doc = Document::with_version(doc.version.clone());
        let mut copied_objects: BTreeMap<ObjectId, ObjectId> = BTreeMap::new();
        let mut new_page_ids = vec![];

        let start_page = i + 1;
        let end_page = (i + split_page_count).min(page_count);

        for page_num in start_page..=end_page {
            if let Some(&page_id) = pages.get(&(page_num as u32)) {
                copy_object_and_dependencies(page_id, &doc, &mut new_doc, &mut copied_objects)?;
                new_page_ids.push(copied_objects.get(&page_id).cloned().unwrap());
            }
        }

        if new_page_ids.is_empty() {
            continue;
        }

        let pages_id = new_doc.add_object(Object::Dictionary(dictionary! {
            "Type" => "Pages",
            "Kids" => new_page_ids.iter().map(|id| Object::Reference(*id)).collect::<Vec<_>>(),
            "Count" => new_page_ids.len() as i64,
        }));

        let catalog_id = new_doc.add_object(Object::Dictionary(dictionary! {
            "Type" => "Catalog",
            "Pages" => Object::Reference(pages_id),
        }));

        new_doc.trailer.set("Root", Object::Reference(catalog_id));

        let filename = format!("{}_{:03}.pdf", filename_only, i / split_page_count + 1);
        let output_path = Path::new(&output_dir).join(&filename);
        new_doc.save(&output_path)?;
        println!("{} を保存しました。", output_path.display());
    }

    Ok(())
}

/// 指定されたオブジェクトとその依存オブジェクトを新しいドキュメントにコピーする
fn copy_object_and_dependencies(
    object_id: ObjectId,
    old_doc: &Document,
    new_doc: &mut Document,
    copied_objects: &mut BTreeMap<ObjectId, ObjectId>,
) -> Result<ObjectId, Box<dyn std::error::Error>> {
    if let Some(new_id) = copied_objects.get(&object_id) {
        return Ok(*new_id);
    }

    // Crucially, insert a placeholder ID before recursing to break cycles.
    let new_id = new_doc.new_object_id();
    copied_objects.insert(object_id, new_id);

    let obj = old_doc.get_object(object_id)?.clone();
    let new_obj = deep_copy_object(obj, old_doc, new_doc, copied_objects)?;
    
    // Now, insert the fully processed object at the placeholder ID.
    new_doc.objects.insert(new_id, new_obj);

    Ok(new_id)
}

/// オブジェクトを深くコピーする関数
fn deep_copy_object(
    obj: Object,
    old_doc: &Document,
    new_doc: &mut Document,
    copied_objects: &mut BTreeMap<ObjectId, ObjectId>,
) -> Result<Object, Box<dyn std::error::Error>> {
    let new_obj = match obj {
        Object::Reference(id) => {
            let new_id = copy_object_and_dependencies(id, old_doc, new_doc, copied_objects)?;
            Object::Reference(new_id)
        }
        Object::Array(arr) => {
            let mut new_arr = vec![];
            for item in arr {
                new_arr.push(deep_copy_object(item, old_doc, new_doc, copied_objects)?);
            }
            Object::Array(new_arr)
        }
        Object::Dictionary(mut dict) => {
            for (_, val) in dict.iter_mut() {
                *val = deep_copy_object(val.clone(), old_doc, new_doc, copied_objects)?;
            }
            Object::Dictionary(dict)
        }
        Object::Stream(mut stream) => {
            for (_, val) in stream.dict.iter_mut() {
                *val = deep_copy_object(val.clone(), old_doc, new_doc, copied_objects)?;
            }
            Object::Stream(stream)
        }
        _ => obj.clone(),
    };
    Ok(new_obj)
}
