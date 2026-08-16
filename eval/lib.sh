#!/usr/bin/env bash
# 各チェックが共通で使う道具(テンプレ v2。出典: secretary-dev で実証した形)。
# 判定は必ず ok / ng / warn / info のどれかで出す。
# 出力の先頭2文字で run-eval.sh が集計するので、自前の echo で判定を書かないこと。
OK=0; NG=0; WARN=0
ok()   { echo "  OK   $*"; OK=$((OK+1)); }
ng()   { echo "  NG   $*"; NG=$((NG+1)); }
warn() { echo "  警告 $*"; WARN=$((WARN+1)); }
info() { echo "  ・   $*"; }
finish(){ echo "  --- OK:$OK 警告:$WARN NG:$NG"; [ "$NG" -eq 0 ]; }

# node があるか。無ければ JS 依存のチェックは丸ごと skip する(skip は warn か ok で言うこと。
# info で言うと出欠(N6)に写らず、検査が消えても誰も気づけない)
have_node(){ command -v node >/dev/null 2>&1; }

# 実測値 $1 が 狙い $2 の ±$3 に収まっているか。
# 数字として読めない物は**必ず外れ**にする。ここを通すと、値の取り出しに失敗した時(空文字)に
# 「近い」と答える検査ができあがり、黙って死ぬ。
near(){
  awk -v a="$1" -v b="$2" -v t="$3" 'BEGIN{
    n="^-?[0-9]+([.][0-9]+)?$";
    if (a !~ n || b !~ n || t !~ n) exit 1;
    d = a - b; if (d < 0) d = -d;
    exit !(d <= t);
  }'
}

# JS を一時ファイルにして実行(--input-type=module は引用符地獄になるので使わない)。
# 置き場所は必ず $ROOT の直下。ESM の相対 import は「実行したファイルの場所」基準なので、
# /tmp に置くと ./lib/… が解決できず「実行できなかった」しか言えなくなる。
run_node(){
  local src="$1"
  local f="$ROOT/.eval-tmp-$$-${RANDOM}.mjs"
  printf '%s' "$src" > "$f"
  ( cd "$ROOT" && node "$f" 2>&1 )
  local rc=$?
  rm -f "$f"
  return $rc
}
