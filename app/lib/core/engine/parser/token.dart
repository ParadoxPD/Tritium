// ============================================================================
// FILE: core/engine/parser/token.dart
// Token types - these rarely change
// ============================================================================

enum TokenType {
  // Literals
  number,
  identifier,
  string,

  // Operators
  plus,
  minus,
  multiply,
  divide,
  power,
  factorial,
  percent,

  // Comparison (for future conditionals)
  equals,
  notEquals,
  lessThan,
  greaterThan,
  lessOrEqual,
  greaterOrEqual,

  // Delimiters
  leftParen,
  rightParen,
  leftBracket,
  rightBracket,
  leftBrace,
  rightBrace,
  comma,
  semicolon,
  colon,

  // Keywords (for future features)
  let,
  if_,
  then,
  else_,
  for_,
  in_,
  store,

  // Special
  root, // √
  imaginaryUnit, // i

  eof,
}

class Token {
  final TokenType type;
  final String lexeme;
  final int position;
  final dynamic literal; // For number tokens

  const Token(this.type, this.lexeme, this.position, {this.literal});

  @override
  String toString() => 'Token($type, "$lexeme",  $position)';
}
