///|
test "token stores span and length" {
  let token = @moonlexkit.Token::new(
    @moonlexkit.TokenKind::Identifier,
    "abc",
    2,
    5,
  )
  assert_eq(token.length(), 3)
  assert_false(token.is_trivia())
}

///|
test "whitespace token is trivia" {
  let token = @moonlexkit.Token::new(
    @moonlexkit.TokenKind::Whitespace,
    " ",
    0,
    1,
  )
  assert_true(token.is_trivia())
}

///|
test "ascii character classifiers" {
  assert_true(@moonlexkit.is_ascii_letter('a'))
  assert_true(@moonlexkit.is_ascii_letter('Z'))
  assert_true(@moonlexkit.is_ascii_digit('7'))
  assert_true(@moonlexkit.is_ascii_whitespace('\n'))
  assert_false(@moonlexkit.is_ascii_digit('x'))
}

///|
test "identifier classifier accepts underscore and digits after first char" {
  assert_true(@moonlexkit.is_identifier_start('_'))
  assert_true(@moonlexkit.is_identifier_part('9'))
  assert_false(@moonlexkit.is_identifier_start('9'))
}

///|
test "lexer config has predictable defaults" {
  let config = @moonlexkit.LexerConfig::default()
  assert_false(config.keep_trivia)
  assert_true(config.emit_end)
}

///|
test "scan identifiers numbers symbols and end token" {
  let tokens = @moonlexkit.scan("foo 123 + bar")
  assert_eq(tokens.length(), 5)
  assert_true(tokens[0] == @moonlexkit.Token::new(Identifier, "foo", 0, 3))
  assert_true(tokens[1] == @moonlexkit.Token::new(Number, "123", 4, 7))
  assert_true(tokens[2] == @moonlexkit.Token::new(Symbol, "+", 8, 9))
  assert_true(tokens[3] == @moonlexkit.Token::new(Identifier, "bar", 10, 13))
  assert_true(tokens[4].kind == End)
}

///|
test "scan can preserve whitespace trivia" {
  let config = @moonlexkit.LexerConfig::new(keep_trivia=true)
  let tokens = @moonlexkit.scan("a  b", config~)
  assert_eq(tokens.length(), 4)
  assert_true(tokens[1] == @moonlexkit.Token::new(Whitespace, "  ", 1, 3))
}

///|
test "scan can omit end token" {
  let config = @moonlexkit.LexerConfig::new(emit_end=false)
  let tokens = @moonlexkit.scan("x", config~)
  assert_eq(tokens.length(), 1)
  assert_true(tokens[0].kind == Identifier)
}

///|
test "token stream advances without losing end safety" {
  let tokens = @moonlexkit.scan("left right")
  let stream = @moonlexkit.TokenStream::new(tokens)
  assert_eq(stream.current().text, "left")
  let stream = stream.advance()
  assert_eq(stream.current().text, "right")
  let stream = stream.advance()
  assert_true(stream.is_at_end())
  let stream = stream.advance().advance()
  assert_true(stream.is_at_end())
}

///|
test "scan with diagnostics reports unknown characters" {
  let result = @moonlexkit.scan_with_diagnostics("ok @")
  assert_true(result.has_errors())
  assert_eq(result.diagnostics.length(), 1)
  assert_eq(result.diagnostics[0].message, "unknown character")
  assert_eq(result.diagnostics[0].start, 3)
}

///|
test "scan with diagnostics accepts clean input" {
  let result = @moonlexkit.scan_with_diagnostics("name = 42")
  assert_false(result.has_errors())
}
