#!/usr/bin/env bash
# 変異試験を全部走らせる。
#
# 「検査は必ず変異試験にかける」という決めごとがある。決めごとは、走らせる手が
# 一本にまとまっていないと、そのうち走らなくなる。一本ずつ思い出して打つ形は、
# 思い出す人がいる間しか続かない(sync.sh が評価を自分で呼ぶのと同じ理由)。
#
# 見つけ方は名前の形(eval/mutate-*.sh)にしてある。一覧を別に持つと、試験を足した時に
# 一覧へ書き足し忘れて、**在るのに走らない試験**ができる。それは黙って緑になる形で、
# 22章で塞いだ穴と同じ。名前で見つければ、置いた瞬間から走る。
#
# 使い方: bash eval/mutate-all.sh
#         bash eval/mutate-all.sh f12    … 名前に f12 を含む試験だけ
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
FILTER="${1:-}"

TOT_P=0; TOT_F=0; TOT_D=0; NSUITE=0; BAD=""

for s in eval/mutate-*.sh; do
  [ -f "$s" ] || continue
  base=$(basename "$s" .sh)
  # 共通部分は試験そのものではない。走らせる物ではないので外す。
  [ "$base" = "mutate-lib" ] && continue
  [ "$base" = "mutate-all" ] && continue
  [ -n "$FILTER" ] && [[ "$base" != *"$FILTER"* ]] && continue
  NSUITE=$((NSUITE+1))
  echo "### $s"
  out=$(bash "$s" 2>&1)
  echo "$out" | grep -vE '^  検知'
  # 締めの一行から数を読む。読めない時は「読めなかった」と言う。
  # 読めないまま 0 として足すと、試験が丸ごと落ちても合計は減らずに緑になる(22章)。
  line=$(printf '%s\n' "$out" | grep -E '^  ---- 検知 ' | tail -1)
  if [ -z "$line" ]; then
    echo "  ⚠ この試験は締めの行を出さずに終わった(途中で落ちた可能性がある)"
    BAD="$BAD $base"
    continue
  fi
  p=$(printf '%s\n' "$line" | sed -E 's/.*検知 ([0-9]+).*/\1/')
  f=$(printf '%s\n' "$line" | sed -E 's/.*取りこぼし ([0-9]+).*/\1/')
  d=$(printf '%s\n' "$line" | sed -E 's/.*変異せず ([0-9]+).*/\1/')
  TOT_P=$((TOT_P+p)); TOT_F=$((TOT_F+f)); TOT_D=$((TOT_D+d))
  { [ "$f" -eq 0 ] && [ "$d" -eq 0 ]; } || BAD="$BAD $base"
done

echo
echo "===== 変異試験 まとめ ====="
# 一本も見つからなかった時に「全部そろっている」と読めてしまわないよう、先に数を見る。
# 20章・N4 と同じ形。空振りは空振りと言う。
if [ "$NSUITE" -eq 0 ]; then
  echo "✗ 変異試験が一本も見つかりませんでした(名前の形か置き場所が変わった可能性があります)"
  exit 1
fi
echo "試験 ${NSUITE} 本 / 検知 ${TOT_P} / 取りこぼし ${TOT_F} / 変異せず ${TOT_D}"
if [ -n "$BAD" ]; then
  echo "✗ 直す必要がある試験:$BAD"
  exit 1
fi

# 走行後の無汚染チェック(監査の視点11 / 2026-08-02)。
# mut_init への渡し忘れ・復元漏れは、ここで名指ししないと本番へ静かに残る。
# さらに「走行中に git commit すると変異の一瞬が封じ込められる」事故が実際に起きた
# (SPEC の 0.15→0.25 が HEAD に入った)。**走行中はコミットしないこと**も込みの見張り。
if [ -d "$ROOT/.git" ]; then
  DIRTY=$(cd "$ROOT" && git status --porcelain -- ':!state' ':!eval/results' 2>/dev/null | head -8)
  if [ -n "$DIRTY" ]; then
    echo "⚠ 変異試験のあと、作業樹に説明のつかない変更が残っている(復元漏れの疑い):"
    echo "$DIRTY"
  fi
fi
echo "✓ すべての変異が検知されました"
