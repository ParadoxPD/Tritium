// ============================================================================
// FILE: core/engine/parser/tokenizer.dart
// Converts string → List<Token>
// ============================================================================

import 'package:app/core/engine/parser/token.dart';
import 'package:app/services/logging_service.dart';

class Tokenizer {
  final String input;
  final List<Token> tokens = [];
  int _start = 0;
  int _current = 0;

  LoggerService logger = LoggerService();

  Tokenizer(this.input);

  List<Token> tokenize() {
    while (!_isAtEnd()) {
      _start = _current;
      _scanToken();
    }

    tokens.add(Token(TokenType.eof, '', _current));
    return tokens;
  }

  void _scanToken() {
    final c = _advance();

    switch (c) {
      // Single characters
      case '(':
        _addToken(TokenType.leftParen);
        break;
      case ')':
        _addToken(TokenType.rightParen);
        break;
      case '[':
        _addToken(TokenType.leftBracket);
        break;
      case ']':
        _addToken(TokenType.rightBracket);
        break;
      case '{':
        _addToken(TokenType.leftBrace);
        break;
      case '}':
        _addToken(TokenType.rightBrace);
        break;
      case ',':
        _addToken(TokenType.comma);
        break;
      case ';':
        _addToken(TokenType.semicolon);
        break;
      case '+':
        _addToken(TokenType.plus);
        break;
      case '-':
        _addToken(TokenType.minus);
        break;
      case '*':
      case '×':
        _addToken(TokenType.multiply);
        break;
      case '/':
      case '÷':
        _addToken(TokenType.divide);
        break;
      case '^':
        _addToken(TokenType.power);
        break;
      case '%':
        _addToken(TokenType.percent);
        break;
      case '√':
        _addToken(TokenType.root);
        break;

      // Multi-character operators
      case '!':
        _addToken(_match('=') ? TokenType.notEquals : TokenType.factorial);
        break;
      case '=':
        if (_match('=')) _addToken(TokenType.equals);
        // Add single '=' assignment here if your engine supports it
        break;
      case '<':
        _addToken(_match('=') ? TokenType.lessOrEqual : TokenType.lessThan);
        break;
      case '>':
        _addToken(
          _match('=') ? TokenType.greaterOrEqual : TokenType.greaterThan,
        );
        break;

      // Ignore whitespace
      case ' ':
      case '\r':
      case '\t':
      case '\n':
        break;

      case '"':
      case "'":
        _string(c);
        break;

      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else if (c == '.' && _isDigit(_peek())) {
          // Handles leading decimals like .5
          _number();
        } else {
          // Instead of returning null, throw a specific error
          logger.error('Unexpected character "$c" at position $_current');
          throw Exception('Unexpected character "$c" at position $_current');
        }
        break;
    }
  }

  // --- Helpers ---

  void _addToken(TokenType type, {Object? literal}) {
    final text = input.substring(_start, _current);
    tokens.add(Token(type, text, _start, literal: literal));
  }

  bool _match(String expected) {
    if (_isAtEnd()) return false;
    if (input[_current] != expected) return false;
    _current++;
    return true;
  }

  void _number() {
    // If it started with a dot, we already consumed it in the switch,
    // but the logic below handles the rest.
    while (_isDigit(_peek())) _advance();

    // Look for a fractional part
    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance(); // Consume the "."
      while (_isDigit(_peek())) _advance();
    }

    // Scientific notation: 1.2e-10
    if ((_peek() == 'e' || _peek() == 'E') &&
        (_isDigit(_peekNext()) || _peekNext() == '-' || _peekNext() == '+')) {
      _advance(); // Consume 'e'
      if (_peek() == '+' || _peek() == '-') _advance();
      while (_isDigit(_peek())) _advance();
    }

    final value = double.parse(input.substring(_start, _current));
    _addToken(TokenType.number, literal: value);
  }

  void _identifier() {
    while (_isAlphaNumeric(_peek())) _advance();

    final text = input.substring(_start, _current);
    final type = _keywords[text] ?? TokenType.identifier;
    _addToken(type);
  }

  void _string(String quote) {
    while (_peek() != quote && !_isAtEnd()) {
      _advance();
    }

    if (_isAtEnd()) throw Exception('Unterminated string.');

    _advance(); // The closing quote
    final value = input.substring(_start + 1, _current - 1);
    _addToken(TokenType.string, literal: value);
  }

  // --- Lookahead & Checks ---

  String _advance() => input[_current++];
  String _peek() => _isAtEnd() ? '\x00' : input[_current];
  String _peekNext() =>
      (_current + 1 >= input.length) ? '\x00' : input[_current + 1];
  bool _isAtEnd() => _current >= input.length;
  bool _isDigit(String c) => RegExp(r'[0-9]').hasMatch(c);
  bool _isAlpha(String c) => RegExp(r'[a-zA-Z_]').hasMatch(c);
  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  static const Map<String, TokenType> _keywords = {
    'let': TokenType.let,
    'if': TokenType.if_,
    'then': TokenType.then,
    'else': TokenType.else_,
    'for': TokenType.for_,
    'in': TokenType.in_,
    'i': TokenType.imaginaryUnit,
    'pi': TokenType.identifier, // You might want a specific type for constants
    'e': TokenType.identifier,
  };
}
