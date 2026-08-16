#!/usr/bin/env bash
# U1 既存テスト(npm test = node --test)を1本の検査に包む。
#
# このリポの実体テスト(test/convert.test.js・test/cli.test.js)はそのまま正本として残し、
# devbase の run-eval コアからも合否が見えるよう、node --test の TAP 集計行(# tests/# pass/
# # fail)を読んで OK/NG に変換するだけの薄いラッパをここに置く(ロジックの二重実装はしない)。
ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
. "$ROOT/eval/lib.sh"

if ! command -v npm >/dev/null 2>&1; then
  warn "U1 npm が無く npm test を検証できない(道具無き機械)"
  finish; exit
fi

OUT=$(cd "$ROOT" && npm test 2>&1)
RC=$?

TESTS=$(printf '%s\n' "$OUT" | grep -oE '^# tests [0-9]+' | grep -oE '[0-9]+' | tail -1)
PASS=$(printf '%s\n' "$OUT" | grep -oE '^# pass [0-9]+' | grep -oE '[0-9]+' | tail -1)
FAIL=$(printf '%s\n' "$OUT" | grep -oE '^# fail [0-9]+' | grep -oE '[0-9]+' | tail -1)

# 集計行が読めない(書式変更・途中で落ちた)場合は、実測値ゼロとして黙って緑にせず NG にする
# (lib.sh の near() と同じ思想=取り出しに失敗した空文字を「近い」と読まない)
if [ "$RC" -ne 0 ] || [ -z "$TESTS" ] || [ -z "$FAIL" ] || [ "$FAIL" != "0" ]; then
  ng "U1 npm test が失敗(exit ${RC}・tests=${TESTS:-?}・pass=${PASS:-?}・fail=${FAIL:-?})"
else
  ok "U1 npm test 全件PASS(tests=${TESTS}・pass=${PASS})"
fi

finish
