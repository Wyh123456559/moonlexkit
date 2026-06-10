///|
pub(all) enum TokenKind {
  Identifier
  Number
  Symbol
  Whitespace
  Unknown
  End
} derive(Eq, Debug)

///|
pub(all) struct Token {
  kind : TokenKind
  text : String
  start : Int
  end : Int
} derive(Eq, Debug)

///|
pub fn Token::new(
  kind : TokenKind,
  text : String,
  start : Int,
  end : Int,
) -> Token {
  { kind, text, start, end }
}

///|
pub fn Token::length(self : Token) -> Int {
  self.end - self.start
}

///|
pub fn Token::is_trivia(self : Token) -> Bool {
  self.kind == Whitespace
}

///|
pub fn is_ascii_letter(ch : Char) -> Bool {
  ch is ('a'..='z' | 'A'..='Z')
}

///|
pub fn is_ascii_digit(ch : Char) -> Bool {
  ch is ('0'..='9')
}

///|
pub fn is_ascii_whitespace(ch : Char) -> Bool {
  ch is (' ' | '\n' | '\r' | '\t')
}

///|
pub fn is_identifier_start(ch : Char) -> Bool {
  is_ascii_letter(ch) || ch == '_'
}

///|
pub fn is_identifier_part(ch : Char) -> Bool {
  is_identifier_start(ch) || is_ascii_digit(ch)
}
