# 作業状態(中断・再開用) — unit-converter

運行: ⚪待機 | 主題: standalone(Discord 運用外)
再開の入口はここ。public npm パッケージ(CLI)であり、devbase の配車(relay-projects.tsv)には
載せない(standalone)。Discord 窓口も持たない。読み順は README.md の「読み順」節を参照。

## これまでに終わったこと(証拠=このリポの git log)

- **CLI 本体(length/mass/temperature 変換)の実装**: `bin/conv.js`(入口)→`src/convert.js`
  (変換ロジック)→`src/units.js`(換算係数表)の3ファイル構成。テスト20件(`test/convert.test.js`・
  `test/cli.test.js`)。
- **CI 配線**: `.github/workflows/ci.yml`(public リポ自己完結版=構文チェック・shellcheck・
  gitleaks)・`.github/dependabot.yml`(週次)。
- **devbase 標準適用(A-2・2026-08-16。台帳 `docs/devenv/plan/satellite-conformance-2026-08-16.md`
  T3)**: 構造選定 ADR(レイヤード最軽量)・`docs/charter.md`・`docs/requirements.md`(R-001〜R-007。
  既存 README の機能を抽出・受け入れ基準=既存テスト名/CI)・`AGENTS.md`・`README.md` を
  README-package 型の章立てへ整形(内容無改変・全角括弧→半角)・`docs/decisions/`(ADR-001+
  INDEX)・`docs/unit-converter/design/ARCHITECTURE.md`(3-C)・`.devbase` 札・`eval/run-eval.sh`
  シム+`eval/criteria.md`+既存テストを1本(`eval/checks/10-npm-test.sh`=U1)に包んだ検査
  (変異試験付き。検知1/取りこぼし0/変異せず0)。`bash eval/run-eval.sh` は OK85/警告1/NG2
  (NG2件は devbase 側 F16a に由来する既知の未対応。詳細は下記「残作業」)。
  `CONFORM_ROOT=~/projects/unit-converter bash ~/projects/devbase/eval/checks/105-conformance.sh`
  は F34a〜e 全 OK。

## 残作業

（空。新規要件が来るまで無し。下記は申し送りのみ。）

**devbase 側 F16a の未対応(申し送り)**: `bash eval/run-eval.sh` の NG2件は、いずれも devbase 側
検査 `eval/checks/75-dev-relay.sh`(F16a)が `scripts/dev-stop-hook.sh`(旧バトン配線パターン)の
存在+特定の実装パターンを要求することに由来する。devbase 自身の `scripts/consumer-stop-hook.sh`
冒頭コメントは「dev-stop-hook.sh は devbase 自身専用、それ以外の consumer は全部
consumer-stop-hook.sh を使う」と明記しており、このリポの Stop hook も実際に
consumer-stop-hook.sh を使っている(F34b/F34e で確認済み)。F16a は旧配線パターンの取り残しで、
consumer-stop-hook.sh 経由の衛星リポ全般(ssp-research・livetr・rpg-overlay・local-llm-assist)に
共通して起きる。このリポの範囲(T3)を超える devbase 側修正が要るため、対症のダミーファイル設置は
せず未対応のまま記録した(ssp-research の WORK-STATE.md にも同内容を記録済み)。

## 参照(再開時のヒント)

- 憲章: `docs/charter.md`。要件: `docs/requirements.md`。構造: `docs/decisions/ADR-001-*`・
  `docs/unit-converter/design/ARCHITECTURE.md`。
- standalone のため相乗り不要。着手する時は `docs/requirements.md` に R-NNN を起こしてから。

## 履歴

- 2026-08-16: 新設(A-2 標準適用・T3)。
