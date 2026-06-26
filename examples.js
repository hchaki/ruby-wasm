const RUBY_EXAMPLES = {
  string: `"こんにちは、世界！"`,
  array: `[1, "two", :three, [4, 5], { key: "value" }]`,
  hash: `{ name: "市川", age: 25, lang: "Ruby" }`,
  range: `(1..10)`,
  symbol: `:ruby_wasm`,
  regexp: `/\\A\\d{3}-\\d{4}\\z/`,
  struct: `Point = Struct.new(:x, :y)\nPoint.new(3, 4)`,
  proc: `greet = ->(name) { "Hello, #{name}" }\ngreet`,
  custom: `class Human
  def initialize(name, age)
    @name = name
    @age = age
  end
  def say = "Hello, " + @name
end

# このオブジェクトを解析する
Human.new("市川", 25)`,
  sandbox: `# WASM サンドボックスの隔離を検証する
results = {}

# 0. ランタイム識別
results["runtime"] = "#{RUBY_PLATFORM} / ruby #{RUBY_VERSION}"

# 1. fork: API ごと存在しない
results["fork"] = Process.respond_to?(:fork) ? "defined" : "undefined (WASIに無い)"

# 2. exec: 仮想FSにホストのバイナリは無い
results["exec"] = begin
  exec("ls", "/")
  "reached after exec(!)"
rescue Exception => e
  "#{e.class}: #{e.message}"
end

# 3. spawn: 子プロセスを作れない
results["spawn"] = begin
  pid = Process.spawn("ls", "/")
  "pid=#{pid.inspect}"
rescue Exception => e
  "#{e.class}: #{e.message}"
end

# 4. backtick: 内部レイヤーが破綻
results["backtick"] = begin
  \`ls /\`
  "ok"
rescue Exception => e
  "#{e.class}: #{e.message}"
end

# 5. system: trueを返す（嘘の成功）が pid=-1
ret = system("definitely_not_a_real_command_xyz_123")
st  = $?
results["system_return"] = ret.inspect
results["system_status"] = "pid=#{st.pid} exit=#{st.exitstatus} success?=#{st.success?}"

# 6. system に副作用が無いことを観測
before = File.exist?("/tmp/wasm_probe") rescue "FS error"
system("touch /tmp/wasm_probe")
after  = File.exist?("/tmp/wasm_probe") rescue "FS error"
results["system_side_effect"] = "before=#{before} after=#{after} (trueなのにファイル作成されない)"

# 7. ホストFSは仮想FS越しでも見えない
results["host_fs"] = begin
  File.read("/etc/passwd")
  "READ HOST FILE (sandbox broken!)"
rescue Exception => e
  "#{e.class}: #{e.message}"
end

# 8. 環境変数はWASIが渡したものだけ
results["env_keys"] = ENV.keys.inspect

results`,
};

const selectEl = document.getElementById("example_select");
const codeEl = document.getElementById("ruby_code");
selectEl.addEventListener("change", (e) => {
  const example = RUBY_EXAMPLES[e.target.value];
  if (example !== undefined) codeEl.value = example;
});
