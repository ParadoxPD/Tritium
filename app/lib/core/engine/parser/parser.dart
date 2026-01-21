// ============================================================================
// FILE: core/engine/parser/parser.dart
// Converts List<Token> → AST (recursive descent parser)
// ============================================================================

import 'package:app/core/engine/parser/ast.dart';
import 'package:app/core/engine/parser/token.dart';
import 'package:app/core/engine_result.dart';

class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  /// Parse a single statement or expression
  ASTNode parse() {
    try {
      return _statement();
    } catch (e) {
      throw EngineError(
        ErrorType.invalidSyntax,
        e.toString(),
        position: _peek().position,
      );
    }
  }

  Statement _statement() {
    if (_match(TokenType.let)) return _letStatement();
    Expression expression = _expression();
    return ExpressionStatement(expression, expression.position);
  }

  LetStatement _letStatement() {
    final name = _consume(TokenType.identifier, 'Expected variable name');
    _consume(TokenType.equals, 'Expected = after variable name');
    final value = _expression();
    return LetStatement(name.lexeme, value, name.position);
  }

  Expression _expression() => _assignment();

  Expression _assignment() {
    final expr = _comparison();
    // Future: handle assignment operators
    return expr;
  }

  Expression _comparison() {
    var expr = _additive();

    while (_match(
      TokenType.equals,
      TokenType.notEquals,
      TokenType.lessThan,
      TokenType.greaterThan,
      TokenType.lessOrEqual,
      TokenType.greaterOrEqual,
    )) {
      final operator = _previous().type;
      final right = _additive();
      expr = BinaryExpression(expr, operator, right, expr.position);
    }

    return expr;
  }

  Expression _additive() {
    var expr = _multiplicative();

    while (_match(TokenType.plus, TokenType.minus)) {
      final operator = _previous().type;
      final right = _multiplicative();
      expr = BinaryExpression(expr, operator, right, expr.position);
    }

    return expr;
  }

  Expression _multiplicative() {
    var expr = _implicitMultiplication();

    while (_match(TokenType.multiply, TokenType.divide)) {
      final operator = _previous().type;
      final right = _implicitMultiplication();
      expr = BinaryExpression(expr, operator, right, expr.position);
    }

    return expr;
  }

  Expression _implicitMultiplication() {
    var expr = _power();

    // Handle implicit multiplication: 2x, 3(x+1), (x+1)(x-1)
    while (_canImplicitMultiply()) {
      final right = _power();
      expr = BinaryExpression(expr, TokenType.multiply, right, expr.position);
    }

    return expr;
  }

  bool _canImplicitMultiply() {
    final current = _peek().type;
    final previous = _current > 0 ? tokens[_current - 1].type : null;

    // After number or ) or ], before ( or identifier
    return (previous == TokenType.number ||
            previous == TokenType.rightParen ||
            previous == TokenType.rightBracket) &&
        (current == TokenType.leftParen ||
            current == TokenType.identifier ||
            current == TokenType.root);
  }

  Expression _power() {
    var expr = _postfix();

    if (_match(TokenType.power)) {
      final right = _power(); // Right associative
      expr = BinaryExpression(expr, TokenType.power, right, expr.position);
    }

    return expr;
  }

  Expression _postfix() {
    var expr = _unary();

    while (true) {
      if (_match(TokenType.factorial)) {
        expr = UnaryExpression(TokenType.factorial, expr, _previous().position);
      } else if (_match(TokenType.percent)) {
        expr = UnaryExpression(TokenType.percent, expr, _previous().position);
      } else {
        break;
      }
    }

    return expr;
  }

  Expression _unary() {
    if (_match(TokenType.minus, TokenType.plus)) {
      final operator = _previous().type;
      final operand = _unary();
      return UnaryExpression(
        operator,
        operand,
        operator == TokenType.minus ? _previous().position : operand.position,
      );
    }

    return _root();
  }

  Expression _root() {
    if (_match(TokenType.root)) {
      final rootPos = _previous().position;

      // Check for index before root (e.g., 3√8)
      Expression? index;
      if (_current > 1 && tokens[_current - 2].type == TokenType.number) {
        // Already consumed, need to backtrack
        // For simplicity, require explicit nthrt() function for custom roots
      }

      final radicand = _call();
      return RootExpression(radicand, index, rootPos);
    }

    return _call();
  }

  Expression _call() {
    var expr = _primary();

    if (expr is IdentifierExpression && _match(TokenType.leftParen)) {
      final args = _arguments();
      _consume(TokenType.rightParen, 'Expected ) after arguments');
      expr = CallExpression(expr.name, args, expr.position);
    }

    return expr;
  }

  List<Expression> _arguments() {
    final args = <Expression>[];

    if (_peek().type == TokenType.rightParen) return args;

    do {
      args.add(_expression());
    } while (_match(TokenType.comma));

    return args;
  }

  Expression _primary() {
    if (_match(TokenType.number)) {
      final token = _previous();
      return NumberLiteral(token.literal as double, token.position);
    }

    if (_match(TokenType.string)) {
      final token = _previous();
      return StringLiteral(token.literal as String, token.position);
    }

    if (_match(TokenType.identifier)) {
      final token = _previous();
      return IdentifierExpression(token.lexeme, token.position);
    }

    if (_match(TokenType.imaginaryUnit)) {
      return NumberLiteral(0, _previous().position); // Will be bound to i
    }

    if (_match(TokenType.leftParen)) {
      final expr = _expression();
      _consume(TokenType.rightParen, 'Expected ) after expression');
      return expr;
    }

    if (_match(TokenType.leftBracket)) {
      return _matrixOrVector();
    }

    if (_match(TokenType.leftBrace)) {
      return _recordLiteral();
    }

    throw EngineError(
      ErrorType.unexpectedToken,
      'Unexpected token: ${_peek().lexeme}',
      position: _peek().position,
    );
  }

  Expression _matrixOrVector() {
    final rows = <List<Expression>>[];
    var currentRow = <Expression>[];

    if (_peek().type == TokenType.rightBracket) {
      _advance();
      return VectorLiteral([], _previous().position);
    }

    do {
      currentRow.add(_expression());

      if (_match(TokenType.semicolon)) {
        rows.add(currentRow);
        currentRow = <Expression>[];
      } else if (_match(TokenType.comma)) {
        continue;
      }
    } while (!_check(TokenType.rightBracket));

    _consume(TokenType.rightBracket, 'Expected ]');

    if (currentRow.isNotEmpty) rows.add(currentRow);

    // Determine if matrix or vector
    if (rows.length == 1) {
      return VectorLiteral(rows[0], rows[0][0].position);
    } else {
      return MatrixLiteral(rows, rows[0][0].position);
    }
  }

  Expression _recordLiteral() {
    final fields = <String, Expression>{};

    while (!_check(TokenType.rightBrace)) {
      final name = _consume(TokenType.identifier, 'Expected field name');
      _consume(TokenType.colon, 'Expected : after field name');
      final value = _expression();
      fields[name.lexeme] = value;

      if (!_match(TokenType.comma)) break;
    }

    _consume(TokenType.rightBrace, 'Expected }');
    return RecordLiteral(fields, fields.values.first.position);
  }

  bool _match(
    TokenType type, [
    TokenType? type2,
    TokenType? type3,
    TokenType? type4,
    TokenType? type5,
    TokenType? type6,
  ]) {
    if (_check(type)) {
      _advance();
      return true;
    }
    if (type2 != null && _check(type2)) {
      _advance();
      return true;
    }
    if (type3 != null && _check(type3)) {
      _advance();
      return true;
    }
    if (type4 != null && _check(type4)) {
      _advance();
      return true;
    }
    if (type5 != null && _check(type5)) {
      _advance();
      return true;
    }
    if (type6 != null && _check(type6)) {
      _advance();
      return true;
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;
  Token _peek() => tokens[_current];
  Token _previous() => tokens[_current - 1];

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw EngineError(
      ErrorType.unexpectedToken,
      message,
      position: _peek().position,
    );
  }
}
