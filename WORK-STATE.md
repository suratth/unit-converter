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
- **devbase 標準適用(A-2・2026-08-16。台帳 `~/projects/devbase/docs/history/satellite-conformance-2026-08-16.md`
  T3)**: 構造選定 ADR(レイヤード最軽量)・`docs/charter.md`・`docs/requirements.md`(R-001〜R-007。
  既存 README の機能を抽出・受け入れ基準=既存テスト名/CI)・`AGENTS.md`・`README.md` を
  README-package 型の章立てへ整形(内容無改変・全角括弧→半角)・`docs/decisions/`(ADR-001+
  INDEX)・`docs/unit-converter/design/ARCHITECTURE.md`(3-C)・`.devbase` 札・`eval/run-eval.sh`
  シム+`eval/criteria.md`+既存テストを1本(`eval/checks/10-npm-test.sh`=U1)に包んだ検査
  (変異試験付き。検知1/取りこぼし0/変異せず0)。新設直後は `bash eval/run-eval.sh` OK85/警告1/NG2
  (NG2件は devbase 側チェック F16a が dev-stop-hook.sh(退役)〔旧バトン配線パターン〕を
  要求していたことに由来。consumer-stop-hook.sh 経由の衛星リポ全般に共通する devbase 側の
  取り残しと判定し、台帳へ申し送った)。**同日、devbase 側 commit `b35b1b4` で F16a が
  `$DEVBASE/scripts/dev-stop-hook.sh` を見るよう修正され解消**。再実行で **OK95/警告0/NG0**。
  `CONFORM_ROOT=~/projects/unit-converter bash ~/projects/devbase/eval/checks/105-conformance.sh`
  は F34a〜e 全 OK。

## 残作業

（空。新規要件が来るまで無し。）

## 参照(再開時のヒント)

- 憲章: `docs/charter.md`。要件: `docs/requirements.md`。構造: `docs/decisions/ADR-001-*`・
  `docs/unit-converter/design/ARCHITECTURE.md`。
- standalone のため相乗り不要。着手する時は `docs/requirements.md` に R-NNN を起こしてから。

## 履歴

- 2026-08-16: 新設(A-2 標準適用・T3)。
