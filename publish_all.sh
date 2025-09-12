#!/bin/bash

set -e

# 設定
APP_NAME="pdf_splitter"
VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
BUILD_DATE=$(date +"%Y-%m-%d")

# プロジェクトルート
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo "PDF Splitter 全プラットフォーム配布パッケージを作成中..."
echo "バージョン: $VERSION"
echo "ビルド日: $BUILD_DATE"
echo ""

# 既存の最終アーカイブを削除
rm -f release-macos.zip release-win.zip

# 1. macOS用パッケージを作成
echo "=== macOS用パッケージを作成中 ==="
./publish.sh

# 2. Windows用パッケージを作成
echo ""
echo "=== Windows用パッケージを作成中 ==="
./publish_windows.sh

# 3. プラットフォーム別ZIPアーカイブを作成
echo ""
echo "=== プラットフォーム別ZIPアーカイブを作成中 ==="

# macOS用アーカイブ
if [ -d "release-macos" ]; then
    echo "release-macos.zip を作成中..."
    zip -r "release-macos.zip" "release-macos/"
    echo "作成完了: release-macos.zip"
else
    echo "警告: release-macos ディレクトリが見つかりません"
fi

# Windows用アーカイブ
if [ -d "release-win" ]; then
    echo "release-win.zip を作成中..."
    zip -r "release-win.zip" "release-win/"
    echo "作成完了: release-win.zip"
else
    echo "警告: release-win ディレクトリが見つかりません"
fi

echo ""
echo "✅ 全プラットフォーム配布パッケージの作成完了!"
echo ""

# ファイルサイズ情報を表示
echo "=== 作成されたアーカイブ ==="
if [ -f "release-macos.zip" ]; then
    MACOS_SIZE=$(ls -lh release-macos.zip | awk '{print $5}')
    echo "📦 release-macos.zip (${MACOS_SIZE})"
    echo "   - macOSアプリバンドル (.app)"
    echo "   - コマンドライン版"
    echo "   - 配布用README"
    echo "   - 設定サンプル"
fi

if [ -f "release-win.zip" ]; then
    WIN_SIZE=$(ls -lh release-win.zip | awk '{print $5}')
    echo "📦 release-win.zip (${WIN_SIZE})"
    echo "   - Windows実行ファイル (.exe)"
    echo "   - 配布用README"
    echo "   - バッチファイルサンプル"
    echo "   - 設定サンプル"
fi

echo ""
echo "=== 個別ファイル構成 ==="

if [ -d "release-macos" ]; then
    echo "📁 release-macos/"
    ls -la release-macos/ | tail -n +2 | while read line; do
        echo "   $line"
    done
    echo ""
fi

if [ -d "release-win" ]; then
    echo "📁 release-win/"
    ls -la release-win/ | tail -n +2 | while read line; do
        echo "   $line"
    done
    echo ""
fi

# GitHubリリース用の情報を生成
if [ "$1" = "--release-notes" ]; then
    echo "=== GitHubリリース用情報 ==="
    echo ""
    cat << EOF
## PDF Splitter v${VERSION}

PDFファイルを指定したページ数で分割するクロスプラットフォーム対応ツールです。

### ダウンロード

#### macOS版
- **release-macos.zip**: macOS用完全パッケージ
  - \`pdf_splitter_macos_v${VERSION}.zip\`: アプリバンドル版（ドラッグ&ドロップ対応）
  - \`pdf_splitter_cli_v${VERSION}.zip\`: コマンドライン版

#### Windows版  
- **release-win.zip**: Windows用完全パッケージ
  - \`pdf_splitter_windows_v${VERSION}.zip\`: 実行ファイル版
  - バッチファイルサンプル付属

### 特徴

- **macOS**: ネイティブアプリバンドル + コマンドライン対応
- **Windows**: シングルバイナリ実行ファイル
- **設定ファイル**: JSON形式で分割ページ数をカスタマイズ
- **ドラッグ&ドロップ**: 直感的なファイル操作

### システム要件

- **macOS**: 10.15以上（Intel/Apple Silicon対応）
- **Windows**: Windows 10/11 (64-bit)

### 使用方法

詳しい使用方法は各パッケージ内の \`README.md\` をご覧ください。

### 変更点

- 初回リリース
- クロスプラットフォーム対応
- JSON設定ファイル対応
- GUI（macOS）+ CUI対応

EOF
fi

echo ""
echo "🎉 すべての作業が完了しました!"
echo ""
echo "配布用アーカイブ:"
echo "- release-macos.zip  : macOS用パッケージ"
echo "- release-win.zip    : Windows用パッケージ"