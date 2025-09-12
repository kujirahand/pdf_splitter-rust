# Makefile for PDF Splitter macOS App

.PHONY: all build clean install publish publish-windows publish-all help

APP_NAME = pdf_splitter
BUNDLE_NAME = $(APP_NAME).app

all: build

# macOSアプリバンドルをビルド
build:
	@echo "Building macOS app bundle..."
	./build_macos_app.sh

# アプリケーションフォルダにインストール
install: build
	@echo "Installing to /Applications..."
	./build_macos_app.sh --install

# ビルド成果物をクリーンアップ
clean:
	@echo "Cleaning up..."
	cargo clean
	rm -rf $(BUNDLE_NAME)
	rm -rf /Applications/$(BUNDLE_NAME)
	rm -rf release-macos
	rm -rf release-win
	rm -f release-macos.zip release-win.zip

# 配布用パッケージを作成（macOS）
publish:
	@echo "Creating macOS distribution packages..."
	./publish.sh

# 配布用パッケージを作成（Windows）
publish-windows:
	@echo "Creating Windows distribution packages..."
	./publish_windows.sh

# 全プラットフォーム配布用パッケージを作成
publish-all:
	@echo "Creating all platform distribution packages..."
	./publish_all.sh

# 配布用パッケージ作成（GitHubリリースノート付き）
publish-release:
	@echo "Creating distribution packages with release notes..."
	./publish_all.sh --release-notes

# Rustのみビルド（デバッグ用）
rust-build:
	cargo build --release

# バンドル構造をテスト表示
test:
	@if [ -d "$(BUNDLE_NAME)" ]; then \
		echo "Bundle structure:"; \
		tree $(BUNDLE_NAME) 2>/dev/null || find $(BUNDLE_NAME) -type f; \
	else \
		echo "Bundle not found. Run 'make build' first."; \
	fi

# ヘルプ
help:
	@echo "Available targets:"
	@echo "  build            - Build macOS app bundle"
	@echo "  install          - Build and install to /Applications"
	@echo "  clean            - Clean up build artifacts"
	@echo "  rust-build       - Build only Rust binary"
	@echo "  test             - Show bundle structure"
	@echo "  publish          - Create macOS distribution packages"
	@echo "  publish-windows  - Create Windows distribution packages"
	@echo "  publish-all      - Create all platform distribution packages"
	@echo "  publish-release  - Create all packages with release notes"
	@echo "  help             - Show this help"