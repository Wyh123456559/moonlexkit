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
