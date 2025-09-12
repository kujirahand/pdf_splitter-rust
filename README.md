# pdf_splitter-rust

A command-line tool for splitting PDF files based on JSON configuration. You can specify how many pages each split should contain using a simple JSON configuration file.

## Features

- Split PDF files into smaller chunks based on page count
- JSON configuration for easy customization
- Automatic configuration file loading
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
pdf_splitter <input.pdf>
```

### Configuration Files

The tool automatically searches for configuration files in the following order:

1. **Executable directory**: `<executable_name>.json` (same directory as the executable)
2. **Home directory**: `~/.pdf_splitter.json`

If no configuration file is found, the default value of 100 pages per split is used.

### Configuration File Format

Create a JSON configuration file with the following format:

```json
{
  "pages": 30
}
```

This configuration will split the PDF every 30 pages.

### Examples

1. **Create a configuration file for 10 pages per split:**

   Create `pdf_splitter.json` in your home directory:
   ```json
   {
     "pages": 10
   }
   ```

   Run the command:
   ```bash
   pdf_splitter document.pdf
   ```

   Output files: `document_1.pdf`, `document_2.pdf`, etc.

2. **Create a configuration file for 50 pages per split:**

   Create a configuration file next to the executable:
   ```json
   {
     "pages": 50
   }
   ```

   Run the command:
   ```bash
   pdf_splitter large_document.pdf
   ```

3. **Split into individual pages:**

   Create `~/.pdf_splitter.json`:
   ```json
   {
     "pages": 1
   }
   ```

   Run the command:
   ```bash
   pdf_splitter document.pdf
   ```

### Output

The tool will create a folder named `{filename}-parts` in the same directory as the input PDF, and save numbered output files inside that folder:
- `{filename}-parts/{filename}_001.pdf` - First split
- `{filename}-parts/{filename}_002.pdf` - Second split
- `{filename}-parts/{filename}_003.pdf` - Third split
- ... and so on

For example, if you split `document.pdf`, the output will be:
- `document-parts/document_001.pdf`
- `document-parts/document_002.pdf`
- `document-parts/document_003.pdf`

## Command Line Options

```
A tool to split PDFs based on JSON configuration

Usage: pdf_splitter <pdf>

Arguments:
  <pdf>     Input PDF file path

Options:
  -h, --help     Print help
  -V, --version  Print version
```

## Configuration File Priority

The tool searches for configuration files in this order:

1. **Executable-specific config**: `<executable_name>.json` in the same directory as the executable
2. **Global user config**: `~/.pdf_splitter.json` in the user's home directory
3. **Default**: If no configuration file is found, uses 100 pages per split

## Requirements

- Valid PDF file as input
- Optional JSON configuration file with `pages` field
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

### 設定ファイルの場所

設定ファイルは以下の順番で自動的に検索されます：

1. **実行ファイルと同じディレクトリ**: `実行ファイル名.json`
2. **ホームディレクトリ**: `~/.pdf_splitter.json`

設定ファイルが見つからない場合は、デフォルトで100ページごとに分割されます。

### 設定例

ホームディレクトリに `~/.pdf_splitter.json` を作成：
```json
{
  "pages": 30
}
```

このJSONファイルを読んで、30ページずつPDFを区切ります。

### 実行方法

```bash
pdf_splitter document.pdf
```

設定ファイルの指定は不要です。自動的に検索されます。

### 出力ファイル

`document.pdf`を分割すると、`document-parts`フォルダが作成され、その中に以下のようなファイルが保存されます：
- `document-parts/document_001.pdf`
- `document-parts/document_002.pdf`
- `document-parts/document_003.pdf`
