use anyhow::{Context, Result};
use lopdf::Document;
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;

#[derive(Debug, Deserialize, Serialize)]
pub struct Config {
    pub pages: u32,
}

pub fn read_config(config_path: &str) -> Result<Config> {
    let config_content = fs::read_to_string(config_path)
        .with_context(|| format!("Failed to read config file: {}", config_path))?;
    
    let config: Config = serde_json::from_str(&config_content)
        .with_context(|| format!("Failed to parse JSON config: {}", config_path))?;
    
    Ok(config)
}

pub fn split_pdf(pdf_path: &str, config: &Config) -> Result<()> {
    // Open the PDF document
    let doc = Document::load(pdf_path)
        .with_context(|| format!("Failed to load PDF: {}", pdf_path))?;

    // Get all page references
    let pages = doc.get_pages();
    let page_numbers: Vec<u32> = pages.keys().copied().collect();
    let total_pages = page_numbers.len();
    
    println!("Total pages in PDF: {}", total_pages);

    if total_pages == 0 {
        return Ok(());
    }

    let pages_per_split = config.pages as usize;
    let num_splits = total_pages.div_ceil(pages_per_split);

    println!("Splitting into {} files with {} pages each", num_splits, pages_per_split);

    // Create output directory if it doesn't exist
    let base_name = Path::new(pdf_path)
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("output");

    for split_index in 0..num_splits {
        let start_page = split_index * pages_per_split;
        let end_page = std::cmp::min(start_page + pages_per_split, total_pages);
        
        println!("Creating split {} with pages {} to {}", split_index + 1, start_page + 1, end_page);
        
        // Create a new document for this split by cloning the original
        let mut new_doc = doc.clone();
        
        // Get the page numbers we want to keep (1-indexed)
        let pages_to_keep: Vec<u32> = (start_page + 1..=end_page).map(|i| i as u32).collect();
        
        // Delete all pages except the ones we want to keep
        let all_page_numbers: Vec<u32> = (1..=total_pages as u32).collect();
        let pages_to_delete: Vec<u32> = all_page_numbers
            .into_iter()
            .filter(|&page_num| !pages_to_keep.contains(&page_num))
            .collect();
        
        // Delete pages in reverse order to avoid index shifting
        for &page_num in pages_to_delete.iter().rev() {
            new_doc.delete_pages(&[page_num]);
        }

        // Save the split PDF
        let output_filename = format!("{}_{:03}.pdf", base_name, split_index + 1);
        new_doc.save(&output_filename)
            .with_context(|| format!("Failed to save split PDF: {}", output_filename))?;
            
        println!("Saved: {}", output_filename);
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use tempfile::tempdir;

    #[test]
    fn test_read_config() {
        let temp_dir = tempdir().unwrap();
        let config_path = temp_dir.path().join("test_config.json");
        
        // Create a test config file
        fs::write(&config_path, r#"{"pages": 25}"#).unwrap();
        
        // Test reading the config
        let config = read_config(config_path.to_str().unwrap()).unwrap();
        assert_eq!(config.pages, 25);
    }

    #[test]
    fn test_read_config_invalid_json() {
        let temp_dir = tempdir().unwrap();
        let config_path = temp_dir.path().join("invalid_config.json");
        
        // Create an invalid config file
        fs::write(&config_path, r#"{"pages": "not_a_number"}"#).unwrap();
        
        // Test reading the config should fail
        assert!(read_config(config_path.to_str().unwrap()).is_err());
    }

    #[test]
    fn test_read_config_missing_file() {
        // Test reading a non-existent config file
        assert!(read_config("/tmp/nonexistent_config.json").is_err());
    }
}