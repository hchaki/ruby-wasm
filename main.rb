require "js"

puts "Hello from main.rb!"

document = JS.global[:document]
output_div = document.getElementById("output")
output_div[:innerText] = "別ファイルのRubyから画面を書き換えたよ！"