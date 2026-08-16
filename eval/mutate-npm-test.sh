#!/usr/bin/env bash
# 変異試験: 既存テスト検査(U1・eval/checks/10-npm-test.sh)が壊れた換算係数を検知できるか。
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
. "$ROOT/eval/mutate-lib.sh"

mut_init "src/units.js"

try "km換算係数を壊す" 10-npm-test.sh \
  m src/units.js "km: 1000," "km: 999,"

mut_done
