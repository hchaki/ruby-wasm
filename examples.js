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
};

const selectEl = document.getElementById("example_select");
const codeEl = document.getElementById("ruby_code");
selectEl.addEventListener("change", (e) => {
  const example = RUBY_EXAMPLES[e.target.value];
  if (example !== undefined) codeEl.value = example;
});
