use clap::{Arg, Command};
use lopdf::{Document, Object, ObjectId, Dictionary};
use anyhow::{Result, anyhow};
use std::path::Path;

fn main() {
    if let Err(e) = run() {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}

fn run() -> Result<()> {
    let matches = Command::new("PDF Splitter")
        .version("0.1.0")
        .author("PDF Splitter Tool")
        .about("A command-line tool to split PDF files")
        .arg(
            Arg::new("input")
                .help("Input PDF file path")
                .required(true)
                .index(1)
        )
        .arg(
            Arg::new("output_dir")
                .help("Output directory for split pages (default: current directory)")
                .short('o')
                .long("output")
                .value_name("DIR")
        )
        .arg(
            Arg::new("prefix")
                .help("Prefix for output files (default: 'page_')")
                .short('p')
                .long("prefix")
                .value_name("PREFIX")
                .default_value("page_")
        )
        .get_matches();

    let input_path = matches.get_one::<String>("input").unwrap();
    let default_output = ".".to_string();
    let output_dir = matches.get_one::<String>("output_dir").unwrap_or(&default_output);
    let prefix = matches.get_one::<String>("prefix").unwrap();

    println!("📄 PDF Splitter - Drag & Drop PDF Splitting Tool");
    println!("Input file: {}", input_path);
    println!("Output directory: {}", output_dir);
    println!("File prefix: {}", prefix);
    println!();

    split_pdf(input_path, output_dir, prefix)?;

    Ok(())
}

fn split_pdf(input_path: &str, output_dir: &str, prefix: &str) -> Result<()> {
    // Check if input file exists
    if !Path::new(input_path).exists() {
        return Err(anyhow!("Input file '{}' does not exist", input_path));
    }

    // Check if input file is a PDF
    if !input_path.to_lowercase().ends_with(".pdf") {
        return Err(anyhow!("Input file must be a PDF (.pdf extension)"));
    }

    // Create output directory if it doesn't exist
    std::fs::create_dir_all(output_dir)?;

    // Load the PDF document
    println!("📖 Loading PDF document...");
    let document = Document::load(input_path)
        .map_err(|e| anyhow!("Failed to load PDF: {}", e))?;

    let pages = document.get_pages();
    let page_count = pages.len();
    println!("✅ Found {} pages in the PDF", page_count);

    if page_count == 0 {
        return Err(anyhow!("PDF has no pages"));
    }

    println!("🔄 Splitting PDF into individual pages...");

    // Split each page using manual extraction
    for (page_num, (&_page_number, &page_id)) in pages.iter().enumerate() {
        let output_filename = format!("{}{:03}.pdf", prefix, page_num + 1);
        let output_path = Path::new(output_dir).join(output_filename);

        match create_single_page_pdf(&document, page_id) {
            Ok(mut single_page_doc) => {
                single_page_doc.save(&output_path)
                    .map_err(|e| anyhow!("Failed to save page {}: {}", page_num + 1, e))?;
                
                println!("  ✅ Page {} -> {}", page_num + 1, output_path.display());
            }
            Err(e) => {
                println!("  ⚠️  Warning: Could not extract page {}: {}", page_num + 1, e);
            }
        }
    }

    println!();
    println!("🎉 Successfully split PDF into {} pages!", page_count);
    println!("📁 Output files saved in: {}", output_dir);

    Ok(())
}

fn create_single_page_pdf(source_doc: &Document, page_id: ObjectId) -> Result<Document> {
    let mut new_doc = Document::with_version("1.5");
    
    // Get the page object
    let page_obj = source_doc.get_object(page_id)
        .map_err(|e| anyhow!("Failed to get page object: {}", e))?;
    
    // Add the page to new document
    let new_page_id = new_doc.add_object(page_obj.clone());
    
    // Create Pages dictionary
    let mut pages_dict = Dictionary::new();
    pages_dict.set("Type", Object::Name(b"Pages".to_vec()));
    pages_dict.set("Kids", Object::Array(vec![Object::Reference(new_page_id)]));
    pages_dict.set("Count", Object::Integer(1));
    
    let pages_id = new_doc.add_object(Object::Dictionary(pages_dict));
    
    // Create Catalog dictionary
    let mut catalog_dict = Dictionary::new();
    catalog_dict.set("Type", Object::Name(b"Catalog".to_vec()));
    catalog_dict.set("Pages", Object::Reference(pages_id));
    
    let catalog_id = new_doc.add_object(Object::Dictionary(catalog_dict));
    
    // Set the root reference in trailer
    new_doc.trailer.set("Root", Object::Reference(catalog_id));
    
    // Set parent reference for the page
    if let Object::Dictionary(page_dict) = new_doc.get_object_mut(new_page_id).unwrap() {
        page_dict.set("Parent", Object::Reference(pages_id));
    }
    
    Ok(new_doc)
}
