# docs/ の置き場ルール(正本)

層: manual / 正本: この文書 / 版: 2026-08-22

<!-- 準拠: devkit/templates/docs-README.md v1。検査 N8(eval/checks/70-doc-placement.sh)がこの表を機械で見張る。 -->

| 置き場 | 置いてよい物 |
|---|---|
| 直下 | README.md(この文書)・ADR.md(案内スタブ)・charter.md・requirements.md・PROJECTS.md(台帳を持つリポだけ) |
| <プロジェクト>/design | 現在形の設計(ARCHITECTURE.md ほか) |
| <プロジェクト>/plan | ROADMAP+spec+開いている台帳(4 行目に状態ヘッダ。済んだら history へ) |
| <プロジェクト>/manual | 手順書(how-to) |
| decisions | ADR 一件一葉+INDEX.md |
| draft / history / old(必要になったら作る) | 共通の逃がし場(下書き/完了の記録/退役原文) |

規定の正本= devrules rules/20-artifact.md(成果物 — 置き場と寿命)。
