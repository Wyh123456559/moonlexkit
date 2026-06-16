///|
pub(all) enum TokenKind {
  Identifier
  Number
  StringLiteral
  Symbol
  Whitespace
  Comment
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
pub(all) struct SourcePosition {
  offset : Int
  line : Int
  column : Int
} derive(Eq, Debug)

///|
pub(all) struct LexerConfig {
  keep_trivia : Bool
  emit_end : Bool
} derive(Eq, Debug)

///|
pub(all) struct TokenStream {
  tokens : Array[Token]
  index : Int
} derive(Eq, Debug)

///|
pub(all) struct Diagnostic {
  message : String
  start : Int
  end : Int
} derive(Eq, Debug)

///|
pub(all) struct LexResult {
  tokens : Array[Token]
  diagnostics : Array[Diagnostic]
} derive(Eq, Debug)

///|
pub(all) struct TokenStats {
  total : Int
  identifiers : Int
  numbers : Int
  strings : Int
  symbols : Int
  trivia : Int
  unknowns : Int
} derive(Eq, Debug)

///|
pub(all) struct ScanSummary {
  tokens : Int
  diagnostics : Int
  identifiers : Int
  numbers : Int
  strings : Int
  comments : Int
  unknowns : Int
  lines : Int
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
pub fn Token::end_at(offset : Int) -> Token {
  Token::new(End, "", offset, offset)
}

///|
pub fn Token::length(self : Token) -> Int {
  self.end - self.start
}

///|
pub fn Token::is_trivia(self : Token) -> Bool {
  self.kind == Whitespace || self.kind == Comment
}

///|
pub fn TokenKind::name(self : TokenKind) -> String {
  match self {
    Identifier => "identifier"
    Number => "number"
    StringLiteral => "string"
    Symbol => "symbol"
    Whitespace => "whitespace"
    Comment => "comment"
    Unknown => "unknown"
    End => "end"
  }
}

///|
pub fn SourcePosition::to_json(self : SourcePosition) -> String {
  "{\"offset\":\{self.offset},\"line\":\{self.line},\"column\":\{self.column}}"
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
pub fn TokenStream::new(tokens : Array[Token]) -> TokenStream {
  { tokens, index: 0 }
}

///|
pub fn TokenStream::current(self : TokenStream) -> Token {
  if self.index < self.tokens.length() {
    self.tokens[self.index]
  } else if self.tokens.length() > 0 {
    Token::end_at(self.tokens[self.tokens.length() - 1].end)
  } else {
    Token::end_at(0)
  }
}

///|
pub fn TokenStream::advance(self : TokenStream) -> TokenStream {
  if self.index < self.tokens.length() {
    { tokens: self.tokens, index: self.index + 1 }
  } else {
    self
  }
}

///|
pub fn TokenStream::is_at_end(self : TokenStream) -> Bool {
  self.current().kind == End
}

///|
pub fn TokenStream::matches_kind(self : TokenStream, kind : TokenKind) -> Bool {
  self.current().kind == kind
}

///|
pub fn TokenStream::consume_kind(
  self : TokenStream,
  kind : TokenKind,
) -> (Bool, Token, TokenStream) {
  let token = self.current()
  if token.kind == kind {
    (true, token, self.advance())
  } else {
    (false, token, self)
  }
}

///|
pub fn Diagnostic::new(message : String, start : Int, end : Int) -> Diagnostic {
  { message, start, end }
}

///|
pub fn LexResult::has_errors(self : LexResult) -> Bool {
  self.diagnostics.length() > 0
}

///|
pub fn LexResult::summary(self : LexResult, source : String) -> ScanSummary {
  let stats = TokenStats::from_tokens(self.tokens)
  {
    tokens: stats.total,
    diagnostics: self.diagnostics.length(),
    identifiers: stats.identifiers,
    numbers: stats.numbers,
    strings: stats.strings,
    comments: count_kind(self.tokens, Comment),
    unknowns: stats.unknowns,
    lines: count_lines(source),
  }
}

///|
pub fn ScanSummary::to_json(self : ScanSummary) -> String {
  "{\"tokens\":\{self.tokens},\"diagnostics\":\{self.diagnostics},\"identifiers\":\{self.identifiers},\"numbers\":\{self.numbers},\"strings\":\{self.strings},\"comments\":\{self.comments},\"unknowns\":\{self.unknowns},\"lines\":\{self.lines}}"
}

///|
pub fn TokenStats::from_tokens(tokens : Array[Token]) -> TokenStats {
  let mut identifiers = 0
  let mut numbers = 0
  let mut strings = 0
  let mut symbols = 0
  let mut trivia = 0
  let mut unknowns = 0
  for token in tokens {
    match token.kind {
      Identifier => identifiers = identifiers + 1
      Number => numbers = numbers + 1
      StringLiteral => strings = strings + 1
      Symbol => symbols = symbols + 1
      Whitespace | Comment => trivia = trivia + 1
      Unknown => unknowns = unknowns + 1
      End => ()
    }
  }
  {
    total: tokens.length(),
    identifiers,
    numbers,
    strings,
    symbols,
    trivia,
    unknowns,
  }
}

///|
pub fn TokenStats::to_json(self : TokenStats) -> String {
  "{\"total\":\{self.total},\"identifiers\":\{self.identifiers},\"numbers\":\{self.numbers},\"strings\":\{self.strings},\"symbols\":\{self.symbols},\"trivia\":\{self.trivia},\"unknowns\":\{self.unknowns}}"
}

///|
fn escape_json(value : String) -> String {
  let buf = StringBuilder()
  for i = 0; i < value.length(); i = i + 1 {
    match value.get_char(i) {
      Some('\\') => buf.write_string("\\\\")
      Some('"') => buf.write_string("\\\"")
      Some('\n') => buf.write_string("\\n")
      Some('\r') => buf.write_string("\\r")
      Some('\t') => buf.write_string("\\t")
      Some(ch) => buf.write_char(ch)
      None => ()
    }
  }
  buf.to_string()
}

///|
pub fn Token::to_json(self : Token) -> String {
  "{\"kind\":\"\{self.kind.name()}\",\"text\":\"\{escape_json(self.text)}\",\"start\":\{self.start},\"end\":\{self.end}}"
}

///|
pub fn tokens_to_json(tokens : Array[Token]) -> String {
  let buf = StringBuilder()
  buf.write_char('[')
  for i = 0; i < tokens.length(); i = i + 1 {
    if i > 0 {
      buf.write_char(',')
    }
    buf.write_string(tokens[i].to_json())
  }
  buf.write_char(']')
  buf.to_string()
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
pub fn count_lines(source : String) -> Int {
  let mut lines = 1
  for i = 0; i < source.length(); i = i + 1 {
    match source.get_char(i) {
      Some('\n') => lines = lines + 1
      _ => ()
    }
  }
  lines
}

///|
pub fn position_at(source : String, offset : Int) -> SourcePosition {
  let safe_offset = if offset < 0 {
    0
  } else if offset > source.length() {
    source.length()
  } else {
    offset
  }
  let mut line = 1
  let mut column = 1
  for i = 0; i < safe_offset; i = i + 1 {
    match source.get_char(i) {
      Some('\n') => {
        line = line + 1
        column = 1
      }
      _ => column = column + 1
    }
  }
  { offset: safe_offset, line, column }
}

///|
pub fn Token::start_position(self : Token, source : String) -> SourcePosition {
  position_at(source, self.start)
}

///|
fn substring(source : String, start : Int, end : Int) -> String {
  source.unsafe_substring(start~, end~)
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
fn is_two_char_symbol(source : String, index : Int) -> Bool {
  match (source.get_char(index), source.get_char(index + 1)) {
    (Some('='), Some('=')) => true
    (Some('!'), Some('=')) => true
    (Some('<'), Some('=')) => true
    (Some('>'), Some('=')) => true
    (Some('-'), Some('>')) => true
    (Some('='), Some('>')) => true
    _ => false
  }
}

///|
fn is_line_comment_start(source : String, index : Int) -> Bool {
  match (source.get_char(index), source.get_char(index + 1)) {
    (Some('/'), Some('/')) => true
    _ => false
  }
}

///|
fn scan_line_comment(source : String, start : Int) -> Int {
  let mut index = start
  while index < source.length() {
    match source.get_char(index) {
      Some('\n' | '\r') => return index
      _ => index = index + 1
    }
  }
  index
}

///|
fn scan_string_literal(source : String, start : Int) -> Int {
  let mut index = start + 1
  let mut escaped = false
  while index < source.length() {
    match source.get_char(index) {
      Some(_) if escaped => {
        escaped = false
        index = index + 1
      }
      Some('\\') => {
        escaped = true
        index = index + 1
      }
      Some('"') => return index + 1
      _ => index = index + 1
    }
  }
  index
}

///|
fn token_ends_with_quote(token : Token) -> Bool {
  if token.text.length() <= 1 {
    false
  } else {
    match token.text.get_char(token.text.length() - 1) {
      Some('"') => true
      _ => false
    }
  }
}

///|
fn count_kind(tokens : Array[Token], kind : TokenKind) -> Int {
  let mut count = 0
  for token in tokens {
    if token.kind == kind {
      count = count + 1
    }
  }
  count
}

///|
fn add_balance_diagnostics(
  tokens : Array[Token],
  diagnostics : Array[Diagnostic],
) -> Unit {
  let mut parens = 0
  let mut braces = 0
  let mut brackets = 0
  for token in tokens {
    if token.kind == Symbol {
      match token.text {
        "(" => parens = parens + 1
        ")" =>
          if parens > 0 {
            parens = parens - 1
          } else {
            diagnostics.push(
              Diagnostic::new("unmatched closing paren", token.start, token.end),
            )
          }
        "{" => braces = braces + 1
        "}" =>
          if braces > 0 {
            braces = braces - 1
          } else {
            diagnostics.push(
              Diagnostic::new("unmatched closing brace", token.start, token.end),
            )
          }
        "[" => brackets = brackets + 1
        "]" =>
          if brackets > 0 {
            brackets = brackets - 1
          } else {
            diagnostics.push(
              Diagnostic::new(
                "unmatched closing bracket",
                token.start,
                token.end,
              ),
            )
          }
        _ => ()
      }
    }
  }
  if parens > 0 {
    diagnostics.push(Diagnostic::new("unclosed paren", 0, 0))
  }
  if braces > 0 {
    diagnostics.push(Diagnostic::new("unclosed brace", 0, 0))
  }
  if brackets > 0 {
    diagnostics.push(Diagnostic::new("unclosed bracket", 0, 0))
  }
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
      Some('"') => {
        let end = scan_string_literal(source, index)
        tokens.push(
          Token::new(StringLiteral, substring(source, index, end), index, end),
        )
        index = end
      }
      Some(_) if is_line_comment_start(source, index) => {
        let end = scan_line_comment(source, index)
        if config.keep_trivia {
          tokens.push(
            Token::new(Comment, substring(source, index, end), index, end),
          )
        }
        index = end
      }
      Some(_) if is_two_char_symbol(source, index) => {
        let end = index + 2
        tokens.push(
          Token::new(Symbol, substring(source, index, end), index, end),
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
        | '='
        | '<'
        | '>'
        | '!') => {
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

///|
pub fn scan_with_diagnostics(
  source : String,
  config? : LexerConfig = LexerConfig::default(),
) -> LexResult {
  let tokens = scan(source, config~)
  let diagnostics : Array[Diagnostic] = []
  for i = 0; i < tokens.length(); i = i + 1 {
    if tokens[i].kind == Unknown {
      diagnostics.push(
        Diagnostic::new("unknown character", tokens[i].start, tokens[i].end),
      )
    } else if tokens[i].kind == StringLiteral &&
      !token_ends_with_quote(tokens[i]) {
      diagnostics.push(
        Diagnostic::new(
          "unterminated string literal",
          tokens[i].start,
          tokens[i].end,
        ),
      )
    }
  }
  add_balance_diagnostics(tokens, diagnostics)
  { tokens, diagnostics }
}
