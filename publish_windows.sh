#!/bin/bash

set -e

# 設定
APP_NAME="pdf_splitter"
VERSION=$(grep '^version' Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/')
BUILD_DATE=$(date +"%Y-%m-%d")
RELEASE_DIR="release-win"

# プロジェクトルート
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

echo "PDF Splitter Windows用配布パッケージを作成中..."
echo "バージョン: $VERSION"
echo "ビルド日: $BUILD_DATE"

# リリースディレクトリをクリーンアップ
if [ -d "$RELEASE_DIR" ]; then
    echo "既存のリリースディレクトリを削除中..."
    rm -rf "$RELEASE_DIR"
fi

mkdir -p "$RELEASE_DIR"

# Windows用ターゲットがインストールされているかチェック
if ! rustup target list --installed | grep -q "x86_64-pc-windows-gnu"; then
    echo "Windows用ターゲットをインストール中..."
    rustup target add x86_64-pc-windows-gnu
fi

# MinGWがインストールされているかチェック
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "MinGWがインストールされていません。"
    echo "macOSでWindows用バイナリをビルドするには、以下のコマンドでMinGWをインストールしてください："
    echo "brew install mingw-w64"
    echo ""
    echo "スキップして他の処理を続行します..."
    SKIP_BUILD=true
else
    SKIP_BUILD=false
fi

# 1. Windows用Rustプロジェクトをクロスコンパイル
if [ "$SKIP_BUILD" = false ]; then
    echo "Windows用Rustプロジェクトをクロスコンパイル中..."
    cargo build --release --target x86_64-pc-windows-gnu
    
    if [ ! -f "target/x86_64-pc-windows-gnu/release/${APP_NAME}.exe" ]; then
        echo "エラー: Windows用バイナリのビルドに失敗しました"
        SKIP_BUILD=true
    fi
else
    echo "Windows用バイナリのビルドをスキップします"
fi

# 2. 配布用README.mdを作成
echo "Windows用配布README.mdを作成中..."
cat > "$RELEASE_DIR/README.md" << 'EOF'
# PDF Splitter for Windows

PDFファイルを指定したページ数で分割するコマンドラインツールです。

## 動作環境

- Windows 10/11 (64-bit)
- .NET Framework や他の追加ランタイムは不要

## インストール方法

1. `pdf_splitter.exe` を任意のフォルダにコピー
2. コマンドプロンプトまたはPowerShellから実行

### PATH環境変数への追加（推奨）

1. `pdf_splitter.exe` を `C:\Program Files\PDF Splitter\` などに配置
2. システム環境変数のPATHに上記フォルダを追加
3. どのフォルダからでも `pdf_splitter` コマンドが使用可能になります

## 使用方法

### コマンドプロンプト / PowerShell

```cmd
# 基本的な使用方法
pdf_splitter.exe document.pdf

# 特定のページ数で分割
pdf_splitter.exe document.pdf 50
```

### エクスプローラーから

1. PDFファイルを `pdf_splitter.exe` にドラッグ&ドロップ
2. 分割されたファイルが元ファイルと同じ場所に作成されます

## 設定

分割するページ数は設定ファイルで変更できます：

1. 実行ファイルと同じフォルダに `pdf_splitter.json` を作成
   ```json
   {
     "pages": 30
   }
   ```

2. またはユーザーのホームフォルダに `.pdf_splitter.json` を配置
   - Windows: `C:\Users\<ユーザー名>\.pdf_splitter.json`

設定ファイルがない場合は、デフォルトで100ページごとに分割されます。

## 出力ファイル

`document.pdf` を分割すると、`document-parts` フォルダが作成され、以下のようなファイルが保存されます：

- `document-parts\document_001.pdf`
- `document-parts\document_002.pdf`
- `document-parts\document_003.pdf`

## トラブルシューティング

### 「Windowsによってコンピューターが保護されました」が表示される場合

1. "詳細情報" をクリック
2. "実行" をクリック

### コマンドが見つからない場合

- ファイルのフルパスを指定して実行してください
- または PATH環境変数にフォルダを追加してください

### ウイルス対策ソフトで検出される場合

- 実行ファイルをウイルス対策ソフトの除外リストに追加してください
- これは署名されていない実行ファイルによる誤検出です

## ライセンス

このソフトウェアは MIT ライセンスの下で配布されています。

## バージョン情報

- バージョン: v{VERSION}
- ビルド日: {BUILD_DATE}
- アーキテクチャ: x86_64 (64-bit)

## サポート

問題が発生した場合は、GitHub リポジトリの Issues でお知らせください：
https://github.com/kujirahand/pdf_splitter-rust

EOF

# バージョン情報を置換
sed -i '' "s/{VERSION}/$VERSION/g" "$RELEASE_DIR/README.md"
sed -i '' "s/{BUILD_DATE}/$BUILD_DATE/g" "$RELEASE_DIR/README.md"

# 3. Windows用バイナリをZIP圧縮
if [ "$SKIP_BUILD" = false ] && [ -f "target/x86_64-pc-windows-gnu/release/${APP_NAME}.exe" ]; then
    echo "Windows用バイナリをZIP圧縮中..."
    cp "target/x86_64-pc-windows-gnu/release/${APP_NAME}.exe" "$RELEASE_DIR/"
    cd "$RELEASE_DIR"
    zip "pdf_splitter_windows_v${VERSION}.zip" "${APP_NAME}.exe" "README.md"
    rm "${APP_NAME}.exe"  # ZIP作成後に削除
    cd "$PROJECT_ROOT"
    echo "作成: $RELEASE_DIR/pdf_splitter_windows_v${VERSION}.zip"
else
    echo "警告: Windows用バイナリが見つかりません。クロスコンパイルをスキップしました。"
    # バイナリなしでもREADMEとサンプル設定は作成
    cd "$RELEASE_DIR"
    zip "pdf_splitter_windows_v${VERSION}_readme_only.zip" "README.md"
    cd "$PROJECT_ROOT"
    echo "作成: $RELEASE_DIR/pdf_splitter_windows_v${VERSION}_readme_only.zip（README のみ）"
fi

# 4. 設定ファイルサンプルを作成
echo "設定ファイルサンプルを作成中..."
cat > "$RELEASE_DIR/pdf_splitter.json" << 'EOF'
{
  "pages": 50
}
EOF

# 5. バッチファイル（.bat）サンプルを作成
echo "バッチファイルサンプルを作成中..."
cat > "$RELEASE_DIR/split_pdf.bat" << 'EOF'
@echo off
echo PDF Splitter for Windows
echo.

if "%~1"=="" (
    echo 使用方法: split_pdf.bat [PDFファイル]
    echo 例: split_pdf.bat document.pdf
    pause
    exit /b 1
)

if not exist "%~1" (
    echo エラー: ファイル "%~1" が見つかりません
    pause
    exit /b 1
)

echo PDFファイルを分割中: %~1
pdf_splitter.exe "%~1"

if %errorlevel% equ 0 (
    echo 分割完了!
) else (
    echo エラーが発生しました
)

pause
EOF

# 6. ライセンスファイルをコピー
if [ -f "LICENSE" ]; then
    cp "LICENSE" "$RELEASE_DIR/"
fi

echo ""
echo "✅ Windows用配布パッケージの作成完了!"
echo ""
echo "作成されたファイル:"
ls -la "$RELEASE_DIR/"
echo ""

if [ "$SKIP_BUILD" = false ]; then
    echo "配布用ファイル:"
    echo "- Windows版: $RELEASE_DIR/pdf_splitter_windows_v${VERSION}.zip"
else
    echo "配布用ファイル（README のみ）:"
    echo "- Windows版: $RELEASE_DIR/pdf_splitter_windows_v${VERSION}_readme_only.zip"
    echo ""
    echo "注意: Windows用バイナリをビルドするには MinGW が必要です："
    echo "brew install mingw-w64"
fi

echo "- 設定サンプル: $RELEASE_DIR/pdf_splitter.json"
echo "- バッチファイル: $RELEASE_DIR/split_pdf.bat"
echo "- 配布用README: $RELEASE_DIR/README.md"
echo ""
echo "🎉 完了しました!"