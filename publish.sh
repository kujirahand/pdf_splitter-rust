#!/bin/bash

set -e

# 設定
APP_NAME="pdf_splitter"
VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
BUILD_DATE=$(date +"%Y-%m-%d")
RELEASE_DIR="release-macos"
BUNDLE_NAME="${APP_NAME}.app"

# プロジェクトルート
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo "PDF Splitter 配布用パッケージを作成中..."
echo "バージョン: $VERSION"
echo "ビルド日: $BUILD_DATE"

# リリースディレクトリをクリーンアップ
if [ -d "$RELEASE_DIR" ]; then
    echo "既存のリリースディレクトリを削除中..."
    rm -rf "$RELEASE_DIR"
fi

mkdir -p "$RELEASE_DIR"

# 1. プロジェクトをビルド
echo "Rustプロジェクトをビルド中..."
cargo build --release

# 2. macOSアプリバンドルをビルド
echo "macOSアプリバンドルをビルド中..."
./build_macos_app.sh

# 3. 配布用README.mdを作成
echo "配布用README.mdを作成中..."
cat > "$RELEASE_DIR/README.md" << 'EOF'
# PDF Splitter

PDFファイルを指定したページ数で分割するツールです。

## 動作環境

- macOS 10.15 以上（Intel/Apple Silicon対応）
- コマンドライン版は Linux/Windows でも利用可能

## インストール方法

### macOSアプリ版

1. `pdf_splitter.app` をアプリケーションフォルダにコピー
2. 初回起動時にセキュリティ警告が出た場合：
   - システム設定 > プライバシーとセキュリティ > セキュリティ
   - "このまま開く" をクリック

### コマンドライン版

1. `pdf_splitter` バイナリを `/usr/local/bin` にコピー
   ```bash
   sudo cp pdf_splitter /usr/local/bin/
   sudo chmod +x /usr/local/bin/pdf_splitter
   ```

## 使用方法

### macOSアプリ版

1. PDFファイルを `pdf_splitter.app` にドラッグ&ドロップ
2. 分割されたファイルが元ファイルと同じ場所に作成されます

### コマンドライン版

```bash
# 基本的な使用方法
pdf_splitter document.pdf

# 特定のページ数で分割
pdf_splitter document.pdf 50
```

## 設定

分割するページ数は設定ファイルで変更できます：

1. ホームディレクトリに `.pdf_splitter.json` を作成
   ```json
   {
     "pages": 30
   }
   ```

2. または実行ファイルと同じディレクトリに `pdf_splitter.json` を配置

設定ファイルがない場合は、デフォルトで100ページごとに分割されます。

## 出力ファイル

`document.pdf` を分割すると、`document-parts` フォルダが作成され、以下のようなファイルが保存されます：

- `document-parts/document_001.pdf`
- `document-parts/document_002.pdf`
- `document-parts/document_003.pdf`

## トラブルシューティング

### macOSで「開発元が未確認のため開けません」と表示される場合

1. ターミナルを開く
2. 以下のコマンドを実行：
   ```bash
   xattr -dr com.apple.quarantine /Applications/pdf_splitter.app
   ```

### コマンドライン版で「command not found」と表示される場合

バイナリが正しくインストールされているか確認：
```bash
which pdf_splitter
```

## ライセンス

このソフトウェアは MIT ライセンスの下で配布されています。

## バージョン情報

- バージョン: v{VERSION}
- ビルド日: {BUILD_DATE}
- 対応アーキテクチャ: arm64 (Apple Silicon), x86_64 (Intel)

## サポート

問題が発生した場合は、GitHub リポジトリの Issues でお知らせください：
https://github.com/kujirahand/pdf_splitter-rust

EOF

# バージョン情報を置換
sed -i '' "s/{VERSION}/$VERSION/g" "$RELEASE_DIR/README.md"
sed -i '' "s/{BUILD_DATE}/$BUILD_DATE/g" "$RELEASE_DIR/README.md"

# 4. macOSアプリバンドルをZIP圧縮
echo "macOSアプリバンドルをZIP圧縮中..."
if [ -d "$BUNDLE_NAME" ]; then
    zip -r "$RELEASE_DIR/pdf_splitter_macos_v${VERSION}.zip" "$BUNDLE_NAME"
    echo "作成: $RELEASE_DIR/pdf_splitter_macos_v${VERSION}.zip"
else
    echo "警告: $BUNDLE_NAME が見つかりません。先にビルドを実行してください。"
fi

# 5. コマンドライン版バイナリをZIP圧縮
echo "コマンドライン版バイナリをZIP圧縮中..."
if [ -f "target/release/$APP_NAME" ]; then
    cp "target/release/$APP_NAME" "$RELEASE_DIR/"
    cd "$RELEASE_DIR"
    zip "pdf_splitter_cli_v${VERSION}.zip" "$APP_NAME" "README.md"
    rm "$APP_NAME"  # ZIP作成後に削除
    cd "$PROJECT_ROOT"
    echo "作成: $RELEASE_DIR/pdf_splitter_cli_v${VERSION}.zip"
else
    echo "警告: target/release/$APP_NAME が見つかりません。先にビルドを実行してください。"
fi

# 6. 設定ファイルサンプルを作成
echo "設定ファイルサンプルを作成中..."
cat > "$RELEASE_DIR/pdf_splitter.json" << 'EOF'
{
  "pages": 50
}
EOF

# 7. ライセンスファイルをコピー
if [ -f "LICENSE" ]; then
    cp "LICENSE" "$RELEASE_DIR/"
fi

echo ""
echo "✅ 配布用パッケージの作成完了!"
echo ""
echo "作成されたファイル:"
ls -la "$RELEASE_DIR/"
echo ""
echo "配布用ファイル:"
echo "- macOSアプリ版: $RELEASE_DIR/pdf_splitter_macos_v${VERSION}.zip"
echo "- コマンドライン版: $RELEASE_DIR/pdf_splitter_cli_v${VERSION}.zip"
echo "- 設定サンプル: $RELEASE_DIR/pdf_splitter.json"
echo "- 配布用README: $RELEASE_DIR/README.md"

# オプション: GitHubリリース用のリリースノートを生成
if [ "$1" = "--release-notes" ]; then
    echo ""
    echo "GitHubリリース用のリリースノート:"
    echo "---"
    cat << EOF
## PDF Splitter v${VERSION}

PDFファイルを指定したページ数で分割するツールです。

### ダウンロード

- **macOSアプリ版**: \`pdf_splitter_macos_v${VERSION}.zip\`
  - Apple Silicon/Intel Mac 対応
  - ドラッグ&ドロップで簡単操作

- **コマンドライン版**: \`pdf_splitter_cli_v${VERSION}.zip\`
  - macOS/Linux/Windows 対応(それぞれのバイナリをダウンロードしてください)
  - ターミナルから直接実行

### 使用方法

詳しい使用方法は同梱の \`README.md\` をご覧ください。

### 変更点

- 初回リリース
- JSON設定ファイル対応
- macOSアプリバンドル対応
- ドラッグ&ドロップ対応

### システム要件

- macOS 10.15 以上
- コマンドライン版は各OSの最新版を推奨
EOF
    echo "---"
fi

echo ""
echo "🎉 すべて完了しました!"