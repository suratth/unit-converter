# 検査観点: unit-converter

層: verification / 正本: この文書 / 版: 2026-08-16

<!-- 準拠: devbase/templates/criteria.md v1。consumer 側の機械検査は「(なし)」表で足りるかを
     実測した(devbase コアの N5/N6 は consumer 側の札が0種だと出欠の突き合わせが空振りしNGに
     なる。ssp-research での2026-08-16実測と同結果)。そのため既存テスト(npm test)を1本の
     検査に包んだ。 -->

| 札 | 観点(何を守るか) | 対応する要件/設計 | 実体 | 変異試験 |
|---|---|---|---|---|
| U1 | 既存テスト(node --test)が全件PASSしている | R-001〜R-006 | `eval/checks/10-npm-test.sh` | `eval/mutate-npm-test.sh` |

- 検査を足したら**必ず変異試験にかける**(G1)。かけない検査は書かない。
- 検査を消す/飛ばす時は OK/NG/警告で白状する(N6 出席の作法)。
