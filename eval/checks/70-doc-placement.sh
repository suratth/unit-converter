#!/usr/bin/env bash
# N8 文書の配置(docs/README.md のルール。テンプレ v4)。
# 「あとで分類」は腐る——置き場違いの md をその場で捕まえる。
# ルール(正本= devbase/verification/docs-layout.md 2節):
#   docs/ 直下に置けるのは README.md(置き場の正本)・ADR.md(decisions/ への案内スタブ)・
#   charter.md・requirements.md(devbase 標準の必置文書。札 F34a がこの道を名指しで見るので
#   種別フォルダへは動かせない)・PROJECTS.md(プロジェクト台帳を持つリポだけ)。
#   プロジェクト別フォルダの下は design / plan / manual の種別だけ
#   (draft / history / old は共通の逃がし場・decisions は ADR 一件一葉+INDEX の置き場=直下 md 可)。
# plan の中身の規則(ROADMAP 1本+spec+開いている台帳・4行目の状態ヘッダ・済んだら history へ)は
# devbase 側の F28o〜r(eval/checks/107-docs-layout.sh)が見る。ここは器の形だけを見る。
ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/eval/lib.sh"

D="$ROOT/docs"
if [ ! -d "$D" ]; then
  warn "N8 docs/ がまだ無い(最初の文書は docs/README.md=配置ルールの正本から始めること)"
  finish; exit
fi
if [ ! -f "$D/README.md" ]; then
  ng "N8 docs/README.md(置き場のルールの正本)が無い"
  finish; exit
fi

bad=""

# 1. docs 直下は名指しで許した5枚だけ
for f in "$D"/*.md; do
  [ -f "$f" ] || continue
  base=$(basename "$f")
  case "$base" in README.md|ADR.md|charter.md|requirements.md|PROJECTS.md) ;; *) bad="$bad 直下:$base" ;; esac
done

# 2. プロジェクト別フォルダの直下に md を直接置かない+種別は design/plan/manual だけ
for p in "$D"/*/; do
  [ -d "$p" ] || continue
  name=$(basename "$p")
  case "$name" in draft|history|old|decisions) continue ;; esac
  for f in "$p"*.md; do
    [ -f "$f" ] && bad="$bad ${name}直下:$(basename "$f")"
  done
  for sub in "$p"*/; do
    [ -d "$sub" ] || continue
    s=$(basename "$sub")
    case "$s" in design|plan|manual) ;; *) bad="$bad ${name}/の未知の種別:$s" ;; esac
  done
done

if [ -n "$bad" ]; then
  ng "N8 置き場のルール違反:$bad(docs/README.md の表に従って置くこと)"
else
  ok "N8 文書の配置がルール(プロジェクト×種別+直下5枚)に従っている"
fi

finish
