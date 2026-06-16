///|
fn main {
  let config = @lex.LexerConfig::new(keep_trivia=true)
  let source = "answer = \"Moon\" // demo\ncall(42)"
  let result = @lex.scan_with_diagnostics(source, config~)
  println(@lex.tokens_to_json(result.tokens))
  println(result.summary(source).to_json())
  println(@lex.position_at(source, 18).to_json())
}
