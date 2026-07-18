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
test "keywords and extended number literals are configurable" {
  let config = @moonlexkit.LexerConfig::new(keywords=["let", "true"])
  let tokens = @moonlexkit.scan("let size = 0xCAFE 12.5e-2 1_000 true", config~)
  assert_true(tokens[0].kind == Keyword)
  assert_eq(tokens[3].text, "0xCAFE")
  assert_eq(tokens[4].text, "12.5e-2")
  assert_eq(tokens[5].text, "1_000")
  assert_true(tokens[6].kind == Keyword)
}

///|
test "nested block comments are trivia and report unterminated input" {
  let config = @moonlexkit.LexerConfig::new(keep_trivia=true)
  let clean = @moonlexkit.scan("a /* outer /* inner */ done */ b", config~)
  assert_true(clean[2].kind == Comment)
  assert_true(clean[2].text.has_suffix("*/"))
  let invalid = @moonlexkit.scan_with_diagnostics("a /* open", config~)
  assert_true(invalid.has_errors())
  assert_eq(invalid.diagnostics[0].message, "unterminated block comment")
}

///|
test "assignment parser recovers after an invalid statement" {
  let parsed = @moonlexkit.parse_assignments(
    "port = 8080; broken + ; name = \"moon\";",
  )
  assert_eq(parsed.assignments.length(), 2)
  assert_eq(parsed.assignments[0].name, "port")
  assert_eq(parsed.assignments[1].value.text, "\"moon\"")
  assert_eq(parsed.diagnostics.length(), 1)
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
test "scan string literals and escaped quotes" {
  let tokens = @moonlexkit.scan("name = \"moon\\\"bit\"")
  assert_eq(tokens.length(), 4)
  assert_true(tokens[2].kind == @moonlexkit.TokenKind::StringLiteral)
  assert_eq(tokens[2].text, "\"moon\\\"bit\"")
  assert_eq(@moonlexkit.TokenKind::StringLiteral.name(), "string")
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
test "scan with diagnostics reports unterminated string" {
  let result = @moonlexkit.scan_with_diagnostics("name = \"open")
  assert_true(result.has_errors())
  assert_eq(result.diagnostics[0].message, "unterminated string literal")
}

///|
test "scan with diagnostics reports delimiter balance" {
  let result = @moonlexkit.scan_with_diagnostics("call(1]")
  assert_true(result.has_errors())
  assert_true(result.diagnostics.length() >= 2)
  assert_eq(result.diagnostics[0].message, "mismatched closing delimiter")
  assert_eq(result.diagnostics[1].start, 4)
}

///|
test "delimiter diagnostics reject crossed nesting" {
  let result = @moonlexkit.scan_with_diagnostics("([)]")
  assert_true(result.has_errors())
  assert_eq(result.diagnostics.length(), 2)
  assert_eq(result.diagnostics[0].message, "mismatched closing delimiter")
  assert_eq(result.diagnostics[0].start, 2)
  assert_eq(result.diagnostics[1].message, "unclosed delimiter")
  assert_eq(result.diagnostics[1].start, 0)
}

///|
test "scan with diagnostics accepts clean input" {
  let result = @moonlexkit.scan_with_diagnostics("name = 42")
  assert_false(result.has_errors())
}

///|
test "token stream consumes expected kind" {
  let stream = @moonlexkit.TokenStream::new(@moonlexkit.scan("sum 10"))
  assert_true(stream.matches_kind(Identifier))
  let (ok, token, next) = stream.consume_kind(Identifier)
  assert_true(ok)
  assert_eq(token.text, "sum")
  assert_true(next.matches_kind(Number))
}

///|
test "token stream keeps position when consume fails" {
  let stream = @moonlexkit.TokenStream::new(@moonlexkit.scan("sum"))
  let (ok, token, next) = stream.consume_kind(Number)
  assert_false(ok)
  assert_eq(token.text, "sum")
  assert_eq(next.index, stream.index)
}

///|
test "scan recognizes common two character symbols" {
  let tokens = @moonlexkit.scan("a == b -> c")
  assert_eq(tokens[1].text, "==")
  assert_eq(tokens[3].text, "->")
  assert_true(tokens[1].kind == Symbol)
}

///|
test "line comments are trivia and can be preserved" {
  let config = @moonlexkit.LexerConfig::new(keep_trivia=true)
  let tokens = @moonlexkit.scan("a // note\nb", config~)
  assert_true(tokens[1].kind == Whitespace)
  assert_true(tokens[2].kind == Comment)
  assert_true(tokens[2].is_trivia())
  assert_eq(tokens[2].text, "// note")
}

///|
test "line comments are skipped by default" {
  let tokens = @moonlexkit.scan("a // note\nb")
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0].text, "a")
  assert_eq(tokens[1].text, "b")
}

///|
test "token kind names are stable for serialization" {
  assert_eq(@moonlexkit.TokenKind::Identifier.name(), "identifier")
  assert_eq(@moonlexkit.TokenKind::Comment.name(), "comment")
  assert_eq(@moonlexkit.TokenKind::End.name(), "end")
}

///|
test "tokens can be exported as json" {
  let tokens = @moonlexkit.scan("a = 1")
  let json = @moonlexkit.tokens_to_json(tokens)
  assert_true(json.contains("\"kind\":\"identifier\""))
  assert_true(json.contains("\"text\":\"a\""))
  assert_true(json.contains("\"kind\":\"end\""))
  let string_json = @moonlexkit.tokens_to_json(@moonlexkit.scan("\"Moon\""))
  assert_true(string_json.contains("\\\"Moon\\\""))
}

///|
test "token json escapes every low control character" {
  let token = @moonlexkit.Token::new(StringLiteral, "\b\u{000C}\u{0001}", 0, 3)
  let json = token.to_json()
  assert_true(json.contains("\\b"))
  assert_true(json.contains("\\f"))
  assert_true(json.contains("\\u0001"))
}

///|
test "token diff isolates one replacement" {
  let old_tokens = @moonlexkit.scan("name = 41")
  let new_tokens = @moonlexkit.scan("name = 42")
  let diff = @moonlexkit.diff_tokens(old_tokens, new_tokens)
  assert_eq(diff.unchanged_prefix, 2)
  assert_eq(diff.unchanged_suffix, 1)
  assert_eq(diff.removed_tokens, 1)
  assert_eq(diff.inserted_tokens, 1)
  assert_eq(diff.old_start, 7)
  assert_eq(diff.old_end, 9)
  assert_eq(diff.new_start, 7)
  assert_eq(diff.new_end, 9)
}

///|
test "token diff reports insertion with trivia precision" {
  let config = @moonlexkit.LexerConfig::new(keep_trivia=true)
  let old_tokens = @moonlexkit.scan("left right", config~)
  let new_tokens = @moonlexkit.scan("left middle right", config~)
  let diff = @moonlexkit.diff_tokens(old_tokens, new_tokens)
  assert_eq(diff.removed_tokens, 0)
  assert_eq(diff.inserted_tokens, 2)
  assert_eq(diff.unchanged_prefix, 2)
  assert_eq(diff.old_start, 5)
  assert_eq(diff.new_start, 5)
  assert_true(diff.to_json().contains("\"inserted_tokens\":2"))
}

///|
test "token diff is empty for identical streams" {
  let tokens = @moonlexkit.scan("same")
  let diff = @moonlexkit.diff_tokens(tokens, tokens)
  assert_eq(diff.unchanged_prefix, tokens.length())
  assert_eq(diff.unchanged_suffix, 0)
  assert_eq(diff.removed_tokens, 0)
  assert_eq(diff.inserted_tokens, 0)
}

///|
test "source positions map offsets to line and column" {
  let source = "one\ntwo"
  let pos = @moonlexkit.position_at(source, 5)
  assert_eq(pos.line, 2)
  assert_eq(pos.column, 2)
  assert_true(pos.to_json().contains("\"line\":2"))
  let token = @moonlexkit.scan(source)[1]
  assert_eq(token.start_position(source).line, 2)
}

///|
test "token stats and scan summary explain token streams" {
  let config = @moonlexkit.LexerConfig::new(keep_trivia=true)
  let result = @moonlexkit.scan_with_diagnostics(
    "name = \"Moon\"\n// note\n42",
    config~,
  )
  let stats = @moonlexkit.TokenStats::from_tokens(result.tokens)
  let summary = result.summary("name = \"Moon\"\n// note\n42")
  assert_eq(stats.identifiers, 1)
  assert_eq(stats.strings, 1)
  assert_eq(summary.comments, 1)
  assert_eq(summary.lines, 3)
  assert_true(stats.to_json().contains("\"strings\":1"))
  assert_true(summary.to_json().contains("\"comments\":1"))
}
