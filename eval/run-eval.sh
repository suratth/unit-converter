#!/usr/bin/env bash
# eval/run-eval.sh — devbase 共通コアの薄いラッパ(secretary の同型を写した)。
# public リポにつき CI(.github/workflows/ci.yml)は run-eval=false のまま(ADR-132。
# GitHub ホストからは private devbase を取れないため)。ローカル/Stop hook から使う。
DEVBASE="${DEVBASE:-$HOME/projects/devbase}"
export CONSUMER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$DEVBASE/eval/run-eval-core.sh" ] || {
  echo "  NG   devbase 継承の断線: $DEVBASE/eval/run-eval-core.sh が無い(DEVBASE の指す先と devbase リポの実在を確認)" >&2
  exit 1
}
exec bash "$DEVBASE/eval/run-eval-core.sh" "$@"
