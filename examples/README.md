# Configuration Examples

This directory contains example JSON configuration files for common PDF splitting scenarios.

## Available Examples

### `split_per_page.json`
Splits the PDF into individual pages (one page per file).
```json
{"pages": 1}
```

### `split_10_pages.json`
Splits the PDF every 10 pages.
```json
{"pages": 10}
```

### `split_30_pages.json`
Splits the PDF every 30 pages (as mentioned in the original requirement).
```json
{"pages": 30}
```

### `split_50_pages.json`
Splits the PDF every 50 pages, useful for large documents.
```json
{"pages": 50}
```

## Usage

To use any of these examples:

```bash
# From the project root directory
pdf_splitter your_document.pdf examples/split_30_pages.json
```

## Creating Custom Configurations

You can create your own configuration files by specifying the desired number of pages per split:

```json
{"pages": YOUR_DESIRED_NUMBER}
```

The `pages` field must be a positive integer.