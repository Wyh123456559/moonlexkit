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
pub fn Token::new(kind : TokenKind, text : String, start : Int, end : Int) -> Token {
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
