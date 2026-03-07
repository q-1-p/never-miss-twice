# CLAUDE.md

このファイルは、リポジトリ内のコードを扱う際に Claude Code (claude.ai/code) へ guidance を提供します。

## プロジェクト構成

Flutter アプリは `app/` サブディレクトリに存在します。Flutter/Dart のコマンドはすべて `app/` から実行してください。

## コマンド

以下のコマンドはすべて `app/` ディレクトリから実行します:

```sh
cd app

# 依存パッケージのインストール
flutter pub get

# アプリの起動
flutter run

# テストの実行
flutter test

# 単一テストファイルの実行
flutter test test/widget_test.dart

# リント
flutter analyze

# コードフォーマット
dart format lib/
```

## アーキテクチャ

このプロジェクトは初期段階であり、現時点ではデフォルトの Flutter カウンターアプリテンプレートです。アプリのエントリーポイントは `app/lib/main.dart` です。

- Dart SDK: `^3.11.1`
- リント: `flutter_lints`（`analysis_options.yaml` で設定）
- 対応プラットフォーム: iOS、Android、macOS、Windows、Linux、Web
