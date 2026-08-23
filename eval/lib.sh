#!/usr/bin/env bash
# 各チェックが共通で使う道具。判定は必ず ok / ng / warn / info のどれかで出す。
# 出力の先頭2文字で run-eval.sh が集計するので、自前の echo で判定を書かないこと。
OK=0; NG=0; WARN=0
# 家の場所を**名前で**引く(パスの直書きをやめるための道具。2026-08-23)。
# 名簿= ~/.config/devhome/houses.tsv(machine-local。どのリポの持ち物でもない)。
# 引けない時は空を返す=呼び手が fail-closed か既定へ倒せる。
house_path() {
  local reg="${DEVHOME_REGISTRY:-$HOME/.config/devhome/houses.tsv}"
  local root="${DEVHOME_ROOT:-$HOME/${DEVHOME_DIR:-projects}}"
  [ -f "$reg" ] || return 1
  local rel; rel=$(awk -F'\t' -v n="$1" '$1==n {print $2; exit}' "$reg")
  [ -n "$rel" ] || return 1
  case "$rel" in /*) printf '%s' "$rel" ;; *) printf '%s/%s' "$root" "$rel" ;; esac
}

ok()   { echo "  OK   $*"; OK=$((OK+1)); }
ng()   { echo "  NG   $*"; NG=$((NG+1)); }
warn() { echo "  警告 $*"; WARN=$((WARN+1)); }
info() { echo "  ・   $*"; }
finish(){ echo "  --- OK:$OK 警告:$WARN NG:$NG"; [ "$NG" -eq 0 ]; }

# node があるか。無ければ JS 依存のチェックは丸ごと skip する
have_node(){ command -v node >/dev/null 2>&1; }

# いまが原作どおり「足痺れ」で触り入口が塞がる窓か(4日に1日・10〜18時のうち1時間)。
# この窓では tools/touch-react.js がモード応答(気分行なし)を返すため、触りを叩く検査は
# 実装が健全でも軒並み落ちる。呼び側は「窓の中なら警告で飛ばす」ために使う
# (37-tipsy の K4 と同じ趣旨を lib/modes.js の tingling() で共有する)。
# 窓の中なら 0、窓の外・判定不能なら非零 → 検査は通常どおり続行する
# (=健全な検査を空振りで飛ばさない。壊れていれば窓の外で普通に NG になる)。
in_tingling_window(){
  have_node || return 1
  local f="$ROOT/.eval-tingle-$$-${RANDOM}.mjs"
  printf 'import { tingling } from "./lib/modes.js"; process.exit(tingling() ? 0 : 1);' > "$f"
  ( cd "$ROOT" && node "$f" ) >/dev/null 2>&1
  local rc=$?
  rm -f "$f"
  return $rc
}

# 実測値 $1 が 狙い $2 の ±$3 に収まっているか。
# 頻度や割合は乱数で決まるので「ぴったり一致」では判定できない。幅で見るしかない。
#
# 数字として読めない物は**必ず外れ**にする。ここを通してしまうと、
# 値の取り出しに失敗した時(空文字)に「近い」と答える検査ができあがり、黙って死ぬ。
near(){
  awk -v a="$1" -v b="$2" -v t="$3" 'BEGIN{
    n="^-?[0-9]+([.][0-9]+)?$";
    if (a !~ n || b !~ n || t !~ n) exit 1;
    d = a - b; if (d < 0) d = -d;
    exit !(d <= t);
  }'
}

# 点検で本物の状態(好感度・学習・時計)を動かさないための隔離。
# lib/*.js は RUSTLICA_STATE_DIR があればそちらを読み書きする。
sandbox_state(){
  RUSTLICA_STATE_DIR=$(mktemp -d /tmp/eval-state-XXXXXX)
  export RUSTLICA_STATE_DIR
  trap 'rm -rf "$RUSTLICA_STATE_DIR"' EXIT
}

# JS を一時ファイルにして実行(--input-type=module は引用符地獄になるので使わない)
#
# 置き場所は必ず $ROOT の直下。ESM の相対 import は「実行したファイルの場所」を基準に
# 解決されるので、/tmp に置くと ./lib/life.js が /tmp/lib/life.js を探しに行って
# 「実行できなかった」しか言えなくなる(=中身を一度も点検できない)。
run_node(){
  local src="$1"
  local f="$ROOT/.eval-tmp-$$-${RANDOM}.mjs"
  printf '%s' "$src" > "$f"
  ( cd "$ROOT" && node "$f" 2>&1 )
  local rc=$?
  rm -f "$f"
  return $rc
}

# プロジェクト固有の補助関数は eval/lib-local.sh に置く(雛形は実プロジェクト情報を持たない約束=三分離)。
# 在れば読む・無ければ黙って進む。共通検査はこの層の関数に依存してはならない(依存するなら共通側へ昇格)。
[ -f "${ROOT:-}/eval/lib-local.sh" ] && . "$ROOT/eval/lib-local.sh"
