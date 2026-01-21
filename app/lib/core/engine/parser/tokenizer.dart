// ============================================================================
// FILE: core/engine/parser/tokenizer.dart
// Converts string → List<Token>
// ============================================================================

import 'package:app/core/engine/parser/token.dart';

class Tokenizer {
  final String input;
  int _current = 0;

  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd()) {
      _skipWhitespace();
      if (_isAtEnd()) break;

      final token = _scanToken();
      if (token != null) tokens.add(token);
    }

    tokens.add(Token(TokenType.eof, '', _current));
    return tokens;
  }

  Token? _scanToken() {
    final start = _current;
    final c = _advance();

    // Single character tokens
    switch (c) {
      case '+':
        return Token(TokenType.plus, c, start);
      case '-':
        return Token(TokenType.minus, c, start);
      case '*':
        return Token(TokenType.multiply, c, start);
      case '/':
        return Token(TokenType.divide, c, start);
      case '^':
        return Token(TokenType.power, c, start);
      case '%':
        return Token(TokenType.percent, c, start);
      case '!':
        return Token(TokenType.factorial, c, start);
      case '(':
        return Token(TokenType.leftParen, c, start);
      case ')':
        return Token(TokenType.rightParen, c, start);
      case '[':
        return Token(TokenType.leftBracket, c, start);
      case ']':
        return Token(TokenType.rightBracket, c, start);
      case '{':
        return Token(TokenType.leftBrace, c, start);
      case '}':
        return Token(TokenType.rightBrace, c, start);
      case ',':
        return Token(TokenType.comma, c, start);
      case ';':
        return Token(TokenType.semicolon, c, start);
      case ':':
        return Token(TokenType.colon, c, start);
      case '√':
        return Token(TokenType.root, c, start);
    }

    // Numbers
    if (_isDigit(c)) return _number(start);

    // Identifiers and keywords
    if (_isAlpha(c)) return _identifier(start);

    // String literals
    if (c == '"' || c == "'") return _string(start, c);

    return null; // Skip unknown characters
  }

  Token _number(int start) {
    while (_isDigit(_peek())) _advance();

    // Decimal point
    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance(); // consume '.'
      while (_isDigit(_peek())) _advance();
    }

    // Scientific notation
    if (_peek() == 'e' || _peek() == 'E') {
      _advance();
      if (_peek() == '+' || _peek() == '-') _advance();
      while (_isDigit(_peek())) _advance();
    }

    final lexeme = input.substring(start, _current);
    final value = double.parse(lexeme);
    return Token(TokenType.number, lexeme, start, literal: value);
  }

  Token _identifier(int start) {
    while (_isAlphaNumeric(_peek())) _advance();

    final lexeme = input.substring(start, _current);

    // Check for keywords
    final type = switch (lexeme) {
      'let' => TokenType.let,
      'if' => TokenType.if_,
      'then' => TokenType.then,
      'else' => TokenType.else_,
      'for' => TokenType.for_,
      'in' => TokenType.in_,
      'i' => TokenType.imaginaryUnit,
      _ => TokenType.identifier,
    };

    return Token(type, lexeme, start);
  }

  Token _string(int start, String quote) {
    while (_peek() != quote && !_isAtEnd()) _advance();

    if (_isAtEnd()) {
      throw Exception('Unterminated string at position $start');
    }

    _advance(); // closing quote
    final value = input.substring(start + 1, _current - 1);
    return Token(TokenType.string, value, start, literal: value);
  }

  void _skipWhitespace() {
    while (!_isAtEnd() && _peek().trim().isEmpty) _advance();
  }

  String _advance() => input[_current++];
  String _peek() => _isAtEnd() ? '\x00' : input[_current];
  String _peekNext() =>
      _current + 1 >= input.length ? '\x00' : input[_current + 1];
  bool _isAtEnd() => _current >= input.length;
  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  bool _isAlpha(String c) {
    final code = c.codeUnitAt(0);
    return (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122) ||
        c == '_';
  }

  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);
}
