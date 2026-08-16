# AGENTS.md: unit-converter

<!-- devbase/templates/AGENTS.md v1 準拠(A-2 標準適用)。人が書いた(丸投げ生成していない)。
     実在確認したコマンドと非自明な罠だけを載せる。詳細は docs/charter.md・README.md が正本。 -->

## コマンド

- 検査: `bash eval/run-eval.sh`(devbase コアへ委譲するシム。consumer 側は `npm test` を1本
  `eval/checks/` に包んで実行する)
- テスト単体: `npm test`(node 組込み `--test`。`test/convert.test.js`=変換ロジック・
  `test/cli.test.js`=CLI の E2E)
- CLI 実行例: `node bin/conv.js 100 km mi`(`npm link` 後は `conv 100 km mi`)

## 構造の約束(逸脱すると本来は CI が落ちる想定だが、現状 dependency-cruiser 未導入)

- 憲章: `docs/charter.md`(選定構造=レイヤード最軽量・NOT リスト)
- 依存規律: `bin/conv.js`→`src/convert.js`→`src/units.js` の一方向のみ。逆方向 import は
  作らないこと(ADR-001)。`.dependency-cruiser.cjs` は3ファイル規模のため未導入(憲章6節)

## この家の非自明な罠

- `src/units.js` の変換係数(`LENGTH_TO_METERS`・`MASS_TO_GRAMS`)を変えると**全変換が静かに狂う**。
  変更したら必ず `test/convert.test.js` の実測値アサーションを通すこと
- 温度(`c`/`f`/`k`)だけは線形換算表に乗らない(`src/convert.js` の `toCelsius`/`fromCelsius` で
  個別計算)。新しい温度単位を足す時は表(`LENGTH_TO_METERS` 的な扱い)ではなく個別分岐に足すこと
- public npm パッケージ(standalone・Discord 運用外)。`~/secretary`・`~/secretary-dev`・devbase の
  配車(relay-projects.tsv)対象ではない。秘密は一切含めない(CI の gitleaks=G9 が唯一の機械の歯止め)
- `.env` 等の秘密は読まない・出力しない

## 判断の作法

- 合否は `bash eval/run-eval.sh`(または `npm test`)が決める。緑にしてから完了を主張する
  (DoD=devbase/manual/process.md)。
- 単位カテゴリの追加・CLI インターフェースの変更は利用者影響が大きいため、実装前に
  `docs/requirements.md` へ R-NNN を起こしてから着手する。
