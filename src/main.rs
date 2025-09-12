use anyhow::Result;
use clap::{Arg, Command};
use pdf_splitter::{read_config, split_pdf};

fn main() -> Result<()> {
    let matches = Command::new("PDF Splitter")
        .version("0.1.0")
        .about("A tool to split PDFs based on JSON configuration")
        .arg(
            Arg::new("pdf")
                .help("Input PDF file path")
                .required(true)
                .index(1),
        )
        .arg(
            Arg::new("config")
                .help("JSON configuration file path")
                .required(true)
                .index(2),
        )
        .get_matches();

    let pdf_path = matches.get_one::<String>("pdf").unwrap();
    let config_path = matches.get_one::<String>("config").unwrap();

    println!("Reading configuration from: {}", config_path);
    let config = read_config(config_path)?;
    println!("Configuration: pages = {}", config.pages);

    println!("Splitting PDF: {}", pdf_path);
    split_pdf(pdf_path, &config)?;

    println!("PDF splitting completed successfully!");
    Ok(())
}
