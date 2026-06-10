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
pub(all) struct LexerConfig {
  keep_trivia : Bool
  emit_end : Bool
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
pub fn LexerConfig::new(
  keep_trivia? : Bool = false,
  emit_end? : Bool = true,
) -> LexerConfig {
  { keep_trivia, emit_end }
}

///|
pub fn LexerConfig::default() -> LexerConfig {
  LexerConfig::new()
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

///|
fn substring(source : String, start : Int, end : Int) -> String {
  let buf = StringBuilder(size_hint=end - start)
  buf.write_substring(source, start, end - start)
  buf.to_string()
}

///|
fn scan_while(source : String, start : Int, accepts : (Char) -> Bool) -> Int {
  let mut index = start
  while index < source.length() {
    match source.get_char(index) {
      Some(ch) if accepts(ch) => index = index + 1
      _ => return index
    }
  }
  index
}

///|
pub fn scan(
  source : String,
  config? : LexerConfig = LexerConfig::default(),
) -> Array[Token] {
  let tokens : Array[Token] = []
  let mut index = 0
  while index < source.length() {
    match source.get_char(index) {
      Some(ch) if is_ascii_whitespace(ch) => {
        let end = scan_while(source, index, is_ascii_whitespace)
        if config.keep_trivia {
          tokens.push(
            Token::new(Whitespace, substring(source, index, end), index, end),
          )
        }
        index = end
      }
      Some(ch) if is_identifier_start(ch) => {
        let end = scan_while(source, index, is_identifier_part)
        tokens.push(
          Token::new(Identifier, substring(source, index, end), index, end),
        )
        index = end
      }
      Some(ch) if is_ascii_digit(ch) => {
        let end = scan_while(source, index, is_ascii_digit)
        tokens.push(
          Token::new(Number, substring(source, index, end), index, end),
        )
        index = end
      }
      Some(ch) if ch
        is ('('
        | ')'
        | '{'
        | '}'
        | '['
        | ']'
        | ','
        | ':'
        | ';'
        | '.'
        | '+'
        | '-'
        | '*'
        | '/'
        | '=') => {
        let end = index + 1
        tokens.push(
          Token::new(Symbol, substring(source, index, end), index, end),
        )
        index = end
      }
      _ => {
        let end = index + 1
        tokens.push(
          Token::new(Unknown, substring(source, index, end), index, end),
        )
        index = end
      }
    }
  }
  if config.emit_end {
    tokens.push(Token::new(End, "", source.length(), source.length()))
  }
  tokens
}
