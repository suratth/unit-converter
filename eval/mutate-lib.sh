#!/usr/bin/env bash
# 変異試験の共通部分。落ちない検査は書いていないのと同じなので、検査を書いたら必ずここを通す。
#
# ■ 治具そのものが黙って壊れた話(必ず読むこと)
#   最初は置換を perl -CSD -i -pe で書いていた。-CSD は**ファイルの中身**を UTF-8 として
#   解読するが、**コマンド行の引数**は解読しない。日本語を含む s/// を渡すと、
#   模様のバイト列と解読済みの文字が食い違い、置換が**何もせずに成功する**。
#   壊れていないファイルで検査が通り、画面には「取りこぼし」と出る。
#   9本中6本がこれで、全部が偽の取りこぼしだった。
#   ここに対策を二つ入れてあるので、新しい変異試験は必ずこれを読み込んで書くこと。
#     1. 置換は正規表現ではなく python3 の**そのままの文字列**置換。見つからなければ失敗する
#     2. 置換のあとファイルが本当に変わったかを cmp で見る。変わっていなければ
#        「変異せず」として、検査の合否とは**別に**数える。治具の壊れを合格に混ぜない
#
# 使い方:
#   . "$ROOT/eval/mutate-lib.sh"
#   mut_init "lib/modes.js tools/touch-react.js"
#   try "名前" 33-modes.sh  m lib/modes.js '元の文字列' '置き換える文字列'
#   mut_done
set -u
# 対象の指し方: 相対= $ROOT 起点(従来) / 絶対= そのまま使う(A-0 第2段: devbase と consumer に跨る試験のため)
mut_path(){ case "$1" in /*) printf '%s' "$1";; *) printf '%s' "$ROOT/$1";; esac; }
PASS=0; FAIL=0; DEAD=0
MUT_TARGETS=""
MUT_BK=""
MUT_TMP=""
declare -A MUT_BASE=()

mut_init(){ # 触るファイルを全部渡す(空白区切り)
  MUT_TARGETS="$1"
  MUT_BK="$(mktemp -d)"
  # 試験の道具が使う捨て場。評価の結果をここへ逃がすと、本物の eval/results/ を汚さない。
  # 汚すと、次の本番の評価が「前回」として試験中の結果を読んでしまう。
  MUT_TMP="$(mktemp -d)"
  local f
  for f in $MUT_TARGETS; do
    [ -f "$(mut_path "$f")" ] || { echo "  変異試験を始められない: $f が無い"; exit 1; }
    cp "$(mut_path "$f")" "$MUT_BK/$(echo "$f" | tr / _)"
  done
  trap 'mut_restore; rm -rf "$MUT_BK" "$MUT_TMP"' EXIT
}

mut_restore(){
  local f
  for f in $MUT_TARGETS; do cp "$MUT_BK/$(echo "$f" | tr / _)" "$(mut_path "$f")"; done
  rm -f "$ROOT"/tools/*.off "$ROOT"/lib/*.off
}

# 変異が実際にファイルへ届いたか。消えている場合も「変異した」とみなす
mut_changed(){
  local f
  for f in $MUT_TARGETS; do
    [ -f "$(mut_path "$f")" ] || return 0
    cmp -s "$(mut_path "$f")" "$MUT_BK/$(echo "$f" | tr / _)" || return 0
  done
  return 1
}

# ファイル 元の文字列 置き換える文字列。1か所だけ、そのままの文字列で置き換える
m(){
  python3 -c '
import sys, io
p, a, b = sys.argv[1:4]
s = io.open(p, encoding="utf-8").read()
if a not in s:
    sys.stderr.write("mutate: 模様が見つからない: " + a + "\n"); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(a, b, 1))
' "$(mut_path "$1")" "$2" "$3"
}

# ファイル 元の文字列 置き換える文字列。**在る分だけ全部**置き換える。
#
# m は一か所しか替えない。同じ一手が二か所以上ある物を「丸ごと消す」試験では、
# 一つ替えても残りが生きているので検査は通り、画面には**取りこぼし**と出る。
# 検査に穴が空いたように見えるが、穴が空いているのは試験の書き方のほうで、
# そのまま信じると直す所を間違える。実際に F12c の二本がこれだった
# (経緯は docs/history/V2-CHANGELOG.md 22章)。
# 「この一手が一つも無い状態」を作りたい時はこちらを使う。
# 一つだけ替えて残りを生かす試験(順番の入れ替えなど)は m のままにする。
mall(){
  python3 -c '
import sys, io
p, a, b = sys.argv[1:4]
s = io.open(p, encoding="utf-8").read()
if a not in s:
    sys.stderr.write("mutate: 模様が見つからない: " + a + "\n"); sys.exit(3)
io.open(p, "w", encoding="utf-8").write(s.replace(a, b))
' "$(mut_path "$1")" "$2" "$3"
}

# 変異をいくつも重ねる。三つ組(ファイル 元 新)を -- で区切って並べる。
#   mm ファイル 元 新 -- ファイル 元 新 -- …
#
# try は渡された語を**一つのコマンド**として呼ぶ。だから
#   try 名 検査  m ファイル A B  m ファイル C D
# と書いても、二つ目の m 以降はぜんぶ一つ目の m の四番目以降の引数になり、
# **黙って捨てられる**。一つ目しか壊れていないのに検査は落ちるので、画面には検知と出る。
# 隣の試験と同じ物を試しているだけなのに、二本あるように見える。実際にそうなっていた。
# 途中で一つでも模様が見つからなければ、そこで止めて失敗を返す(try が「模様が古い」と言う)。
mm(){
  local -a g=()
  local x
  for x in "$@" '--'; do
    if [ "$x" = '--' ]; then
      [ "${#g[@]}" -eq 3 ] || { echo "mm: 三つ組(ファイル 元 新)を -- で区切ること" >&2; return 2; }
      m "${g[0]}" "${g[1]}" "${g[2]}" || return 3
      g=()
    else
      g+=("$x")
    fi
  done
}

try(){ # 名前 期待して落ちる検査 変異コマンド…
  local name="$1" check="$2"; shift 2
  mut_restore
  if ! ( cd "$ROOT" && "$@" ) >/dev/null 2>&1; then
    echo "  変異失敗    $name  (置換コマンドが失敗した。模様が古い)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  if ! mut_changed; then
    echo "  変異せず    $name  (ファイルが変わっていない。検査ではなく治具の壊れ)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  # 検査の所在: consumer に無ければ devbase 側(A-0 第2段=共通検査の移送先)を見る
  local chkpath="$ROOT/eval/checks/$check"
  case "$check" in /*) chkpath="$check";; esac
  [ -f "$chkpath" ] || chkpath="${DEVKIT:-$HOME/projects/supply/devkit}/eval/checks/$check"
  if bash "$chkpath" >/dev/null 2>&1; then
    echo "  取りこぼし  $name  ($check が通ってしまった)"; FAIL=$((FAIL+1))
  else
    echo "  検知        $name  ($check)"; PASS=$((PASS+1))
  fi
  mut_restore
}

# 壊す前の出力を一度だけ取って覚える。同じ走らせ方なら二度目からは覚えた物を返す。
mut_baseline(){
  local key="$1"
  if [ -z "${MUT_BASE[$key]+x}" ]; then
    mut_restore
    MUT_BASE[$key]=$( cd "$ROOT" && eval "$key" 2>&1 )
  fi
  printf '%s\n' "${MUT_BASE[$key]}"
}

# 名前 「走らせ方(シェルの一行)」 「出てほしい文字列」 変異コマンド…
#
# try は「検査が非零で終わること」で検知を数える。それだけでは届かない所が二つある。
#   ・**警告は落ちない**。lib.sh の決まりで、非零になるのは NG だけ。
#     だから警告で知らせる項目(G2 など)は、try では一本も試験できない。
#   ・**検査ファイルではない物が出す判定**がある。N5・N6 は eval/run-eval.sh が出すので、
#     eval/checks/ の下を叩いても永久に出てこない。
# どちらも「落ちるか」ではなく「**そう言うか**」でしか確かめられない。
#
# 言うか言わないかで見る試験には、固有の落とし穴がある。**壊す前から言っている**文字列を
# 待ってしまうと、何を壊しても検知になり、試験が全部素通りで緑になる。
# だから壊す前の出力を先に取り、そこに出ていないことを確かめてから壊す。
# 確かめずに数えると、20章・N4 と同じ「成立していない測り方」になる。
try_says(){
  local name="$1" runner="$2" want="$3"; shift 3
  mut_restore
  if mut_baseline "$runner" | grep -qF -- "$want"; then
    echo "  試験にならない  $name  (壊す前から「$want」と言っている)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  if ! ( cd "$ROOT" && "$@" ) >/dev/null 2>&1; then
    echo "  変異失敗    $name  (置換コマンドが失敗した。模様が古い)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  if ! mut_changed; then
    echo "  変異せず    $name  (ファイルが変わっていない。検査ではなく治具の壊れ)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  local out
  out=$( cd "$ROOT" && eval "$runner" 2>&1 )
  if printf '%s\n' "$out" | grep -qF -- "$want"; then
    echo "  検知        $name  (「$want」と言った)"; PASS=$((PASS+1))
  else
    echo "  取りこぼし  $name  (「$want」と言わなかった)"; FAIL=$((FAIL+1))
  fi
  mut_restore
}

# 名前 「走らせ方(シェルの一行)」 「消えてはいけない文字列」 変異コマンド…
#
# try_says の裏返し。**言わなくなったこと**を検知とみなす。
# 「走るはずの検査が黙って消える」は、新しい NG が出るのではなく、
# 今まで出ていた行が無くなる形で起きる。出た物を見る試験だけでは届かない。
try_silent(){
  local name="$1" runner="$2" gone="$3"; shift 3
  mut_restore
  if ! mut_baseline "$runner" | grep -qF -- "$gone"; then
    echo "  試験にならない  $name  (壊す前から「$gone」と言っていない)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  if ! ( cd "$ROOT" && "$@" ) >/dev/null 2>&1; then
    echo "  変異失敗    $name  (置換コマンドが失敗した。模様が古い)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  if ! mut_changed; then
    echo "  変異せず    $name  (ファイルが変わっていない。検査ではなく治具の壊れ)"; DEAD=$((DEAD+1)); mut_restore; return
  fi
  local out
  out=$( cd "$ROOT" && eval "$runner" 2>&1 )
  if printf '%s\n' "$out" | grep -qF -- "$gone"; then
    echo "  取りこぼし  $name  (「$gone」が消えていない)"; FAIL=$((FAIL+1))
  else
    echo "  検知        $name  (「$gone」が消えた)"; PASS=$((PASS+1))
  fi
  mut_restore
}

mut_done(){
  echo "  ---- 検知 $PASS / 取りこぼし $FAIL / 変異せず $DEAD"
  # 実走の台帳(ADR-010 残穴「変異数の自己申告」対策・2026-08-22)。報告の「変異 N/N」の
  # 根拠を eval/results/mutation-log.tsv に残し、F48(119-mutation-log.sh)が stamp 再計算と
  # 鮮度(検査を直した後に回したか)を照合する。式は平文にある=完全ではないが、
  # printf 一発の偽造では stamp が合わない(N11f・run-eval 実行証明と同型のコスト上げ)。
  local mroot mhead mline mstamp
  mroot="${ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
  mhead=$(git -C "$mroot" rev-parse HEAD 2>/dev/null || echo nohead)
  mline="$(date -Iseconds)	$(basename "$0")	$PASS	$FAIL	$DEAD	$mhead"
  mstamp=$(printf '%b\n' "$mline" | sha1sum | cut -c1-16)
  mkdir -p "$mroot/eval/results" 2>/dev/null && \
    printf '%b\t%s\n' "$mline" "$mstamp" >> "$mroot/eval/results/mutation-log.tsv" 2>/dev/null || true
  [ "$FAIL" -eq 0 ] && [ "$DEAD" -eq 0 ]
}
