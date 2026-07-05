///|
fn source_fixture(lines : Int, changed_line? : Int = -1) -> String {
  let output = StringBuilder()
  for line = 0; line < lines; line = line + 1 {
    output.write_string("item_\{line} = ")
    if line == changed_line {
      output.write_string("99999")
    } else {
      output.write_string(line.to_string())
    }
    output.write_string(" // row\n")
  }
  output.to_string()
}

///|
fn main {
  let lines = 10000
  let config = @lex.LexerConfig::new(keep_trivia=true)
  let original = source_fixture(lines)
  let changed = source_fixture(lines, changed_line=5000)
  let first = @lex.scan_with_diagnostics(original, config~)
  let second = @lex.scan_with_diagnostics(changed, config~)
  let diff = @lex.diff_tokens(first.tokens, second.tokens)
  println("lines=\{lines}")
  println("source_units=\{original.length()}")
  println("tokens=\{first.tokens.length()}")
  println("diagnostics=\{first.diagnostics.length()}")
  println("summary=" + first.summary(original).to_json())
  println("diff=" + diff.to_json())
}
