#!/usr/bin/env bash
# eval/run-eval.sh — 検査の入口(テンプレ v3=共通コアへの薄いシム。三分離 S2 以後の標準形)。
# 二枝走査: このリポ自前の eval/checks/* と、共通検査(実体= devkit。移行期は devbase 経由)を
# 番号順に走らせ、出欠(N5/N6)まで機械で突き合わせる。
# 自己完結(standalone)で運用するリポだけ、旧スタンドアロン核(git 履歴の v2)へ差し替えてよい。
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export CONSUMER_ROOT="$SELF"
CORE="${DEVKIT:-$HOME/projects/devkit}/eval/run-eval-core.sh"
[ -f "$CORE" ] || {
  echo "  NG   検査の断線: 共通コア($CORE)が無い(継承経路の破れ。fail-closed)" >&2
  exit 1
}
exec bash "$CORE" "$@"
