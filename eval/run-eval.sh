#!/usr/bin/env bash
# eval/run-eval.sh — devkit 共通コアの薄いラッパ(三分離 S5 W2)。
# public リポにつき CI(.github/workflows/ci.yml)は run-eval=false のまま(ADR-132。
# GitHub ホストからは private devbase を取れないため)。ローカル/Stop hook から使う。
DEVKIT="${DEVKIT:-$HOME/projects/devkit}"
export CONSUMER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$DEVKIT/eval/run-eval-core.sh" ] || {
  echo "  NG   devkit 継承の断線: $DEVKIT/eval/run-eval-core.sh が無い(DEVKIT の指す先と devkit リポの実在を確認)" >&2
  exit 1
}
exec bash "$DEVKIT/eval/run-eval-core.sh" "$@"
