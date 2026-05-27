# Ruby オブジェクト視覚化デバッガー

[Ruby.wasm](https://github.com/ruby/ruby.wasm) を使って、ブラウザ上で Ruby コードを実行し、**最後の行の評価結果（オブジェクト）の構造を視覚化** するシンプルなツールです。

クラス名・継承ツリー・インスタンス変数・利用可能なメソッドを一覧表示します。
Ruby のオブジェクトモデルやメタプログラミングを学ぶ際のお供にどうぞ。

## 使い方

ローカルにクローンして、静的サーバーで `index.html` を配信するだけです。

```sh
# 例: Python の組み込みサーバーを使う
python3 -m http.server 8000

# 例: Ruby なら
ruby -run -e httpd . -p 8000
```

ブラウザで `http://localhost:8000/` を開いてください。

> [!NOTE]
> `file://` で直接開くと `main.rb` の読み込みでエラーになります。必ず HTTP サーバー経由で開いてください。

## 操作

1. **例文を選ぶ** セレクトから好きな Ruby オブジェクトを選ぶと、textarea に例文が入ります
2. textarea を自由に編集し、最後の行に解析したいオブジェクトを置きます
3. **オブジェクトを解析！** ボタンを押すと結果が下に表示されます

## 例文として用意されているオブジェクト

- 文字列 (String)
- 配列 (Array)
- ハッシュ (Hash)
- 範囲 (Range)
- シンボル (Symbol)
- 正規表現 (Regexp)
- Struct
- Proc / Lambda
- 自作クラス (Human)

## ファイル構成

| ファイル        | 役割                                                        |
| --------------- | ----------------------------------------------------------- |
| `index.html`    | エントリポイント。UI と Ruby.wasm の読み込み                |
| `main.rb`       | ブラウザ上で動く Ruby 本体。`eval` でコードを実行し解析する |
| `examples.js`   | セレクト変更時に textarea を書き換える JS                   |
| `style.css`     | スタイル                                                    |

## 仕組み

- `<script type="text/ruby">` が CDN 経由の Ruby.wasm によって解釈されます
- `main.rb` 側で JS の `window.analyzeRubyObject` に Ruby の lambda を登録
- ボタンクリックで textarea の文字列を `eval(code, TOPLEVEL_BINDING)` し、戻り値を解析して HTML を組み立て直します
