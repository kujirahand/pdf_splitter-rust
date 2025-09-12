#!/bin/bash

set -e

# 設定
APP_NAME="pdf_splitter"
BUNDLE_NAME="${APP_NAME}.app"
BUNDLE_ID="com.example.pdfsplitter"

# プロジェクトルート
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
MACOS_BUNDLE_DIR="$PROJECT_ROOT/macos-bundle"

# 出力ディレクトリ
OUTPUT_DIR="$PROJECT_ROOT"
BUNDLE_DIR="$OUTPUT_DIR/$BUNDLE_NAME"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

echo "macOSアプリケーションバンドルをビルドしています..."

# 既存のバンドルがあれば削除
if [ -d "$BUNDLE_DIR" ]; then
    echo "既存のバンドル $BUNDLE_DIR を削除中..."
    rm -rf "$BUNDLE_DIR"
fi

# ディレクトリ構造を作成
echo "バンドルディレクトリ構造を作成中..."
mkdir -p "$CONTENTS_DIR"
mkdir -p "$MACOS_DIR"

# 1. Rustプロジェクトをリリースビルド
echo "Rustプロジェクトをビルド中..."
cd "$PROJECT_ROOT"
cargo build --release

# 2. Rustバイナリをバンドルにコピー
echo "Rustバイナリをコピー中..."
cp "$PROJECT_ROOT/target/release/$APP_NAME" "$MACOS_DIR/pdf_splitter_bin"

# 3. Objective-Cラッパーをコンパイル
echo "Objective-Cラッパーをコンパイル中..."
clang -framework Cocoa \
    -o "$MACOS_DIR/$APP_NAME" \
    "$MACOS_BUNDLE_DIR/main.m"

# 4. Info.plistをコピー
echo "Info.plistをコピー中..."
cp "$MACOS_BUNDLE_DIR/Info.plist" "$CONTENTS_DIR/"

# 5. 実行権限を設定
echo "実行権限を設定中..."
chmod +x "$MACOS_DIR/$APP_NAME"
chmod +x "$MACOS_DIR/pdf_splitter_bin"

echo "ビルド完了!"
echo "作成されたバンドル: $BUNDLE_DIR"
echo ""
echo "バンドル構造:"
tree "$BUNDLE_DIR" 2>/dev/null || {
    echo "$BUNDLE_NAME"
    echo "└── Contents"
    echo "    ├── Info.plist"
    echo "    └── MacOS"
    echo "        ├── $APP_NAME"
    echo "        └── pdf_splitter_bin"
}

# オプション: バンドルをアプリケーションフォルダにコピー
if [ "$1" = "--install" ]; then
    echo ""
    echo "アプリケーションフォルダにインストール中..."
    if [ -d "/Applications/$BUNDLE_NAME" ]; then
        rm -rf "/Applications/$BUNDLE_NAME"
    fi
    cp -R "$BUNDLE_DIR" "/Applications/"
    echo "インストール完了: /Applications/$BUNDLE_NAME"
fi