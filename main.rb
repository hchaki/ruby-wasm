require "js"

# --- 道具箱：Rubyのメタプログラミング魔法 ---
# 1. eval(string) : 文字列をRubyのコードとして実行する
# 2. obj.class   : オブジェクトのクラスを返す
# 3. obj.instance_variables : 持っているインスタンス変数名の配列を返す
# 4. obj.instance_variable_get(sym) : 変数名（シンボル）から値を取得する
# 5. obj.methods : 使えるメソッド一覧の配列を返す
# --------------------------------------------

# JSのグローバル空間（window）に、Rubyの関数（lambda）を登録する
# HTMLのボタンの onclick="window.analyzeRubyObject()" から呼び出される
JS.global[:analyzeRubyObject] = lambda do |*args|

  # --- 1. ブラウザの画面からコードを取得 ---
  document = JS.global[:document]
  code_area = document.getElementById("ruby_code")
  result_area = document.getElementById("result_output")

  # textarea の値を取得（JSオブジェクトなので to_s でRubyの文字列にする）
  code = code_area[:value].to_s

  puts "Trying to evaluate code..."
  result_area[:innerHTML] = "Thinking..."

  begin
    # --- 2. コードを実行（eval） ---
    # ブラウザ上のサンドボックスなので安全！TOPLEVEL_BINDING で実行してクラス定義などを保持する
    target_object = eval(code, TOPLEVEL_BINDING)

    # eval は最後の行の評価結果を返す。今回はそれが解析対象。
    # もし最後の結果が nil なら解析を中止
    if target_object.nil? && code.strip.split("\n").last.include?("#")
       raise "最後の行がコメント、または空です。解析対象のオブジェクトを最後の行に置いてください。"
    end

    # --- 3. オブジェクトの構造を解析してHTMLを組み立てる ---
    cls = target_object.class
    obj_id = target_object.object_id

    html = []
    html << "<h2>解析対象: <span class='v-obj-inspect'>#{target_object.inspect}</span></h2>"

    html << "<ul>"

    # 基本情報：クラス名と継承ツリー
    ancestors = cls.ancestors.take(5).map(&:name).join(" -&gt; ")
    html << "<li><strong>クラス:</strong> #{cls.name}</li>"
    html << "<li><strong>継承:</strong> <small>#{ancestors}</small></li>"
    html << "<li><strong>Object ID:</strong> #{obj_id}</li>"

    # A. インスタンス変数（オブジェクトの「状態」）
    html << "<li><strong>インスタンス変数 (@):</strong>"
    ivars = target_object.instance_variables
    if ivars.empty?
      html << " なし"
    else
      html << " <ul class='v-list'>"
      ivars.each do |ivar|
        # 変数名から値を取得
        value = target_object.instance_variable_get(ivar)
        html << "    <li><code>#{ivar}</code>: <span class='v-obj-inspect'>#{value.inspect}</span></li>"
      end
      html << " </ul>"
    end
    html << "</li>"

    # B. メソッド（オブジェクトの「能力」）
    # あまりに多いので、そのオブジェクト独自のメソッド（inherited=false）だけ抽出、または先頭100個に絞る
    html << "<li><strong>利用可能なメソッド (先頭100個):</strong><br>"
    # sort して、take(100) し、JSの画面用に整形
    methods_list = target_object.methods.sort.take(100).map do |m|
      "<code>#{m}</code>"
    end.join(", ")
    html << "<div class='v-methods'>#{methods_list}</div>"
    html << "</li>"

    html << "</ul>"

    # --- 4. 完成したHTMLをJS側に渡して画面を更新 ---
    result_area[:innerHTML] = html.join("\n")
    puts "Success!"

  rescue => e
    # エラーが発生した場合（構文エラーなど）は赤文字で表示
    result_area[:innerHTML] = "<span style='color: red;'><strong>Error:</strong> #{e.message}</span>"
    puts "Error: #{e.message}"
  end
end

puts "Ruby object analyzer bridge loaded."

# --- 追加：Rubyの準備ができたらボタンを有効化する ---
btn = JS.global[:document].getElementById("analyze_btn")
btn[:disabled] = false
btn[:innerText] = "オブジェクトを解析！"