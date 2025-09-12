# pdf_splitter-rust

A command-line tool for splitting PDF files using Rust. This tool provides a drag & drop style interface where you can easily split a PDF file into individual pages.

## Features

- 🔧 Split PDF files into individual pages
- 📁 Customizable output directory
- 🏷️ Customizable filename prefix for output files
- ⚡ Fast and efficient processing using Rust
- 💯 Zero external dependencies for PDF processing

## Installation

### From Source

1. Make sure you have Rust installed. If not, install it from [rustup.rs](https://rustup.rs/)

2. Clone the repository:
```bash
git clone https://github.com/kujirahand/pdf_splitter-rust.git
cd pdf_splitter-rust
```

3. Build the project:
```bash
cargo build --release
```

4. The executable will be available at `target/release/pdf_splitter`

## Usage

### Basic Usage

Split a PDF file into individual pages in the current directory:

```bash
./pdf_splitter input.pdf
```

### Advanced Usage

Specify output directory and filename prefix:

```bash
./pdf_splitter input.pdf -o output_folder -p "page_"
```

### Options

- `<input>`: Input PDF file path (required)
- `-o, --output <DIR>`: Output directory for split pages (default: current directory)
- `-p, --prefix <PREFIX>`: Prefix for output files (default: 'page_')
- `-h, --help`: Show help information
- `-V, --version`: Show version information

### Examples

1. Split `document.pdf` into pages in the current directory:
```bash
./pdf_splitter document.pdf
```
Output: `page_001.pdf`, `page_002.pdf`, `page_003.pdf`, ...

2. Split with custom output directory:
```bash
./pdf_splitter document.pdf -o split_pages
```
Output: `split_pages/page_001.pdf`, `split_pages/page_002.pdf`, ...

3. Split with custom prefix:
```bash
./pdf_splitter document.pdf -p "chapter_"
```
Output: `chapter_001.pdf`, `chapter_002.pdf`, `chapter_003.pdf`, ...

4. Combine options:
```bash
./pdf_splitter document.pdf -o chapters -p "ch_"
```
Output: `chapters/ch_001.pdf`, `chapters/ch_002.pdf`, ...

## Drag & Drop Usage

While this is a command-line tool, it supports "drag & drop" style usage where you can:

1. Drop a PDF file onto the executable (on systems that support it)
2. Use it in file manager scripts
3. Create shortcuts or aliases for quick access

## Error Handling

The tool provides clear error messages for common issues:

- File not found
- Invalid PDF files
- Permission errors
- Disk space issues

## Development

### Building for Development

```bash
cargo build
```

### Running Tests

```bash
cargo test
```

### Creating a Test PDF

A test PDF with 3 pages is included in the `test_data` directory for testing purposes.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Requirements

- Rust 1.70 or later
- Compatible with Windows, macOS, and Linux
