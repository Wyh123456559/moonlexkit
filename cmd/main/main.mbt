///|
fn main {
  let config = @lex.LexerConfig::new(keep_trivia=true)
  let tokens = @lex.scan("answer = 42 // demo", config~)
  println(@lex.tokens_to_json(tokens))
}
