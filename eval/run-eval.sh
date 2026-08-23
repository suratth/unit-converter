#!/usr/bin/env bash
# 由来: devkit templates/eval/run-eval.sh(雛形所有の種= 更新装置が上書きする。直す時は雛形へ還流する)
# eval/run-eval.sh — 検査の入口(テンプレ v4=共通コアへの薄いシム)。
# 二枝走査: このリポ自前の eval/checks/* と、継承元(雛形)の共通検査を番号順に走らせ、
# 出欠(N5/N6)まで機械で突き合わせる。
# 自己完結(standalone)で運用するリポだけ、この家の中に自前の核を置いて差し替えてよい。
#
# 継承元の**場所は名簿から引く**(~/.config/devhome/houses.tsv)。旧い置き場(symlink)で
# 呼ぶと、装置が自分の在処を symlink 側で認識して、hooks の配線や検収の比較先が
# 実パスとずれる(2026-08-23 に実測: 同じ配線装置が呼ばれ方で違う出力を出した)。
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CONSUMER_ROOT="$SELF"
if [ -z "${DEVKIT:-}" ]; then
  REG="${DEVHOME_REGISTRY:-$HOME/.config/devhome/houses.tsv}"
  HOMEROOT="${DEVHOME_ROOT:-$HOME/${DEVHOME_DIR:-projects}}"
  REL=$(awk -F'\t' '$1=="devkit" {print $2; exit}' "$REG" 2>/dev/null)
  case "$REL" in
    '') DEVKIT="" ;;
    /*) DEVKIT="$REL" ;;
    *)  DEVKIT="$HOMEROOT/$REL" ;;
  esac
fi
CORE="$DEVKIT/eval/run-eval-core.sh"
[ -n "$DEVKIT" ] && [ -f "$CORE" ] || {
  echo "  NG   検査の断線: 共通コア run-eval-core.sh が無い(継承経路の破れ。名簿= $REG。fail-closed)" >&2
  exit 1
}
exec bash "$CORE" "$@"
