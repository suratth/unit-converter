#!/usr/bin/env bash
# N8(文書の配置。70-doc-placement.sh)の変異試験(テンプレの種)。
# 捨て場に最小 docs ツリー(fixture)を作り ROOT で検査をそちらへ向ける。
# 検査を書いたら必ず変異試験にかける(G1)——この種は雛形が配り、リポ固有の追加検査の手本を兼ねる。
# 追加型の変異(ファイル/フォルダが「生える」)は mut_init の追跡外なので手で判定する
# (共通検査の変異試験と同じ型)。
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="${ROOT:-$SELF}"
. "$ROOT/eval/mutate-lib.sh"
CHK="$ROOT/eval/checks/70-doc-placement.sh"
[ -f "$CHK" ] || { echo "  変異試験を始められない: $CHK が無い"; exit 1; }

FIX="$(mktemp -d)"; mkdir -p "$FIX/eval" "$FIX/docs/myproj/design"
cp "$ROOT/eval/lib.sh" "$FIX/eval/lib.sh"
printf '# 置き場のルール(fixture)\n' > "$FIX/docs/README.md"
printf '# 設計メモ\n' > "$FIX/docs/myproj/design/note.md"
export ROOT="$FIX"
bash "$CHK" >/dev/null 2>&1 || { echo "  変異試験を始められない: fixture のままで N8 が NG"; bash "$CHK"; exit 1; }
mut_init "$FIX/docs/README.md $CHK"

# 追加型: 壊す→検査が言うか→片付ける、を手で数える
grow() { # 説明 仕込みコマンド...
  local name="$1"; shift
  "$@"
  if bash "$CHK" >/dev/null 2>&1; then
    echo "  取りこぼし  $name  ($(basename "$CHK") が通ってしまった)"; FAIL=$((FAIL+1))
  else
    echo "  検知        $name  ($(basename "$CHK"))"; PASS=$((PASS+1))
  fi
}
# ① 直下に許可外の md が生える → NG
grow "docs 直下に野良 md が生える" bash -c 'printf x > "$1/docs/stray.md"' _ "$FIX"
rm -f "$FIX/docs/stray.md"
# ② プロジェクトフォルダ直下に md を直置き → NG
grow "プロジェクトフォルダ直下に md を直置き" bash -c 'printf x > "$1/docs/myproj/loose.md"' _ "$FIX"
rm -f "$FIX/docs/myproj/loose.md"
# ③ 未知の種別フォルダが生える → NG
grow "未知の種別フォルダ(notes/)が生える" bash -c 'mkdir -p "$1/docs/myproj/notes"' _ "$FIX"
rmdir "$FIX/docs/myproj/notes" 2>/dev/null || true
# ④ 置き場ルールの正本(docs/README.md)が消える → NG
try "docs/README.md(ルールの正本)が消える" "$CHK" rm "$FIX/docs/README.md"
# ⑤ 検査自身の生存確認: 違反集計の構文が壊れる → 非零で落ちるはず
try "違反集計の構文が壊れる(検査自身の生存確認)" "$CHK" m "$CHK" 'bad=""' 'bad=(""'
mut_restore; mut_done
