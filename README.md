# unit-converter

<!-- 準拠: devbase/templates/README-package.md v1(配布物型)。公開リポ向け=層ヘッダ不要。
     内容は既存版から無改変(章立てのみテンプレへ整形・全角括弧は半角へ)。 -->

長さ・重さ・温度を変換するNode.js製のCLIツールです。

## インストール

```bash
git clone https://github.com/suratth/unit-converter.git
cd unit-converter
npm link
```

`npm link`すると`conv`コマンドがどこからでも使えるようになります。リンクせずに直接実行する場合は
`node bin/conv.js ...`または`./bin/conv.js ...`を使ってください。

## 使い方

```
conv <value> <from> <to>
```

### オプション

| オプション | 説明 |
|---|---|
| `-l`, `--list` | 対応している単位の一覧を表示 |
| `-h`, `--help` | 使い方を表示 |
| `--precision <n>` | 出力の小数点以下桁数を指定(デフォルト: 4) |

```bash
conv --list
conv 100 km mi --precision 2
# 62.14
```

## 例

```bash
conv 100 km mi
# 62.1371

conv 32 f c
# 0

conv 5 kg lb
# 11.0231
```

## 対応単位

| カテゴリ | 単位 |
|---|---|
| 長さ | `km`, `m`, `cm`, `mm`, `mi`, `yd`, `ft`, `in` |
| 重さ | `kg`, `g`, `mg`, `lb`, `oz` |
| 温度 | `c`, `f`, `k` |

単位名は大文字・小文字を区別しません。異なるカテゴリ間の変換(例: `km`→`kg`)はエラーになります。

## テスト

```bash
npm test
```

`node --test`を使った単体テスト(変換ロジック)とE2Eテスト(CLI実行結果)が実行されます。

## 読み順(関連文書)

憲章 [`docs/charter.md`](docs/charter.md) → 要件 [`docs/requirements.md`](docs/requirements.md) →
構造 [`docs/unit-converter/design/ARCHITECTURE.md`](docs/unit-converter/design/ARCHITECTURE.md) →
決定 [`docs/decisions/INDEX.md`](docs/decisions/INDEX.md)
