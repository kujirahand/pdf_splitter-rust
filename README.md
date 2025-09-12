# pdf_splitter-rust

A command-line tool for splitting PDF files based on JSON configuration. You can specify how many pages each split should contain using a simple JSON configuration file.

## Features

- Split PDF files into smaller chunks based on page count
- JSON configuration for easy customization
- Simple command-line interface
- Preserves PDF quality and structure
- Automatic naming of output files

## Installation

### Build from source

1. Make sure you have Rust installed: https://rustup.rs/
2. Clone this repository:
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

```bash
pdf_splitter <input.pdf> <config.json>
```

### Configuration File

Create a JSON configuration file that specifies how many pages each split should contain:

```json
{"pages": 30}
```

This configuration will split the PDF every 30 pages.

### Examples

1. **Split a document every 10 pages:**

   Create `config.json`:
   ```json
   {"pages": 10}
   ```

   Run the command:
   ```bash
   pdf_splitter document.pdf config.json
   ```

   Output files: `document_001.pdf`, `document_002.pdf`, etc.

2. **Split a large document every 50 pages:**

   Create `config.json`:
   ```json
   {"pages": 50}
   ```

   Run the command:
   ```bash
   pdf_splitter large_document.pdf config.json
   ```

3. **Split into individual pages:**

   Create `config.json`:
   ```json
   {"pages": 1}
   ```

   Run the command:
   ```bash
   pdf_splitter document.pdf config.json
   ```

### Output

The tool will create numbered output files in the same directory as the input PDF:
- `{filename}_001.pdf` - First split
- `{filename}_002.pdf` - Second split
- `{filename}_003.pdf` - Third split
- ... and so on

## Command Line Options

```
A tool to split PDFs based on JSON configuration

Usage: pdf_splitter <pdf> <config>

Arguments:
  <pdf>     Input PDF file path
  <config>  JSON configuration file path

Options:
  -h, --help     Print help
  -V, --version  Print version
```

## Requirements

- Valid PDF file as input
- JSON configuration file with `pages` field
- Write permissions in the output directory

## Error Handling

The tool provides clear error messages for common issues:
- Missing or invalid PDF files
- Invalid JSON configuration files
- Missing `pages` field in configuration
- File permission issues

## Development

### Running Tests

```bash
cargo test
```

### Development Dependencies

- `serde` and `serde_json` for JSON parsing
- `lopdf` for PDF processing
- `clap` for command-line interface
- `anyhow` for error handling
- `tempfile` for testing (dev dependency)

## License

This project is licensed under the terms specified in the LICENSE file.

## Japanese / 日本語

このツールは、JSON設定ファイルに基づいてPDFファイルを分割します。

### 使用例

設定ファイル（JSON）に以下のように指定：
```json
{"pages": 30}
```

そのJSONファイルを読んで、30ページずつPDFを区切ります。

### 実行方法

```bash
pdf_splitter document.pdf config.json
```
