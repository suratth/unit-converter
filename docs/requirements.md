# 要件定義: unit-converter

層: requirements / 正本: この文書 / 版: 2026-08-16

<!-- devbase/templates/requirements.md v1 準拠(A-2 標準適用)。内容は既存 README.md の機能を
     R-NNN へ抽出したもの(発明しない)。受け入れ基準は既存テスト名/CI を指す。 -->

## R-001: 単位変換(長さ・重さ・温度)

- **何を**: `conv <value> <from> <to>` を実行すると、長さ(km/m/cm/mm/mi/yd/ft/in)・
  重さ(kg/g/mg/lb/oz)・温度(c/f/k)のいずれかで変換した結果を標準出力へ表示する。
- **なぜ**: ブラウザ検索なしでターミナルから即座に単位変換したい(憲章1節)。
- **受け入れ基準**: `test/convert.test.js`(変換ロジック9件)・`test/cli.test.js` の
  `basic length conversion`・`basic temperature conversion` が PASS。
- **状態**: 実装済

## R-002: 単位名は大文字小文字を区別しない

- **何を**: `KM`・`km`・`Km` のように大文字小文字が混在していても同じ単位として扱う。
- **なぜ**: 入力の揺れを利用者に強制しないため。
- **受け入れ基準**: `test/convert.test.js` の `length: case-insensitive units` が PASS。
- **状態**: 実装済

## R-003: 出力精度の指定(--precision)

- **何を**: `--precision <n>` で出力の小数点以下桁数を指定できる(既定4桁)。
- **なぜ**: 用途に応じた丸め桁数の調整。
- **受け入れ基準**: `test/cli.test.js` の
  `--precision option controls decimal places` が PASS。
- **状態**: 実装済

## R-004: 対応単位の一覧表示(-l/--list)

- **何を**: `-l`・`--list` を渡すとカテゴリ別(length/mass/temperature)の対応単位一覧を表示する。
- **なぜ**: 利用者が対応単位をコード/ドキュメントを読まずに確認できるようにするため。
- **受け入れ基準**: `test/cli.test.js` の `--list prints unit categories` が PASS。
- **状態**: 実装済

## R-005: 使い方の表示(-h/--help)

- **何を**: `-h`・`--help` を渡すと USAGE 文言を表示して正常終了する。引数無しでも USAGE を
  表示するが、この場合は終了コード1(R-006と共通の入口)。
- **なぜ**: 利用者がオプション名を忘れても迷わないため。
- **受け入れ基準**: 手動確認(README 記載の USAGE 文言と一致)。専用の自動テストは無い
  (`test/cli.test.js` の `missing arguments shows usage and exits 1` が引数無し経路のみを担保)。
- **状態**: 実装済

## R-006: 不正な入力のエラー処理

- **何を**: 引数の数が不正・数値として読めない値・未知の単位名・カテゴリ不一致(例: km→kg)の
  いずれも、原因を示すメッセージを標準エラーへ出し終了コード1で終わる(例外を投げっぱなしにしない)。
- **なぜ**: 誤った入力でスタックトレースを見せず、利用者に直せる形で伝えるため。
- **受け入れ基準**: `test/cli.test.js` の `missing arguments shows usage and exits 1`・
  `invalid number reports an error`・`unknown unit reports an error`・
  `mismatched categories reports an error` が PASS。
- **状態**: 実装済

## R-007: CI による品質ゲート(公開リポの秘密漏洩防止)

- **何を**: push・PR のたびに GitHub Actions(`.github/workflows/ci.yml`)が構文チェック
  (`bash -n`/`node --check`)・shellcheck・gitleaks(G9)を回す。
- **なぜ**: public npm パッケージであり、秘密漏洩や壊れた構文の公開を防ぐため。
- **受け入れ基準**: 直近の CI run が緑(GitHub Actions の run 結果)。
- **状態**: 実装済

## 履歴

- 2026-08-16: 起草(A-2 標準適用・最小)。既存 README.md の機能を R-001〜R-007 へ抽出。
