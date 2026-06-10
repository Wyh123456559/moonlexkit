///|
test "token stores span and length" {
  let token = @moonlexkit.Token::new(@moonlexkit.TokenKind::Identifier, "abc", 2, 5)
  assert_eq(token.length(), 3)
  assert_false(token.is_trivia())
}

///|
test "whitespace token is trivia" {
  let token = @moonlexkit.Token::new(@moonlexkit.TokenKind::Whitespace, " ", 0, 1)
  assert_true(token.is_trivia())
}
