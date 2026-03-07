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

モジュラーモノリス + DDD + クリーンアーキテクチャ。エントリーポイントは `app/lib/main.dart`。

```
app/lib/
├── main.dart                          # DI wiring
├── core/
│   └── use_case.dart                  # 抽象 UseCase 基底クラス
├── domain/
│   └── habit/                         # 関心：habit のドメイン（純 Dart）
│       ├── habit.dart                 # エンティティ
│       ├── habit_date.dart            # 日付ユーティリティ
│       ├── streak_status.dart         # StreakStatus enum
│       ├── habit_repository.dart      # 抽象インターフェース
│       ├── add_habit.dart             # UseCase
│       ├── remove_habit.dart          # UseCase
│       ├── toggle_completion.dart     # UseCase
│       ├── get_habits.dart            # UseCase
│       ├── get_streak_status.dart     # UseCase
│       └── get_at_risk_count.dart     # UseCase
├── data/
│   └── habit/                         # 関心：habit のインフラ
│       ├── habit_model.dart           # DTO
│       ├── habit_local_source.dart    # SharedPreferences ラッパー
│       ├── dock_badge_source.dart     # MethodChannel ラッパー
│       └── habit_repository_impl.dart # HabitRepository 実装
└── presentation/
    └── habit/                         # 関心：habit の UI
        ├── habit_notifier.dart        # ChangeNotifier
        ├── home_screen.dart
        ├── add_habit_dialog.dart
        └── habit_list_item.dart
```

依存方向: `presentation → domain`、`data → domain`、`domain` は外部依存なし。

- Dart SDK: `^3.11.1`
- 状態管理: `provider`
- 永続化: `shared_preferences`
- リント: `flutter_lints`
- 対応プラットフォーム: iOS、Android、macOS、Windows、Linux、Web
