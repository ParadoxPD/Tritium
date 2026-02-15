import 'package:app/core/engine/parser/ast.dart';
import 'package:app/core/engine/parser/token.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/services/logging_service.dart';

class Parser {
  final List<Token> tokens;
  int _current = 0;

  final logger = LoggerService();
  Parser(this.tokens);

  /// Parse a single statement or expression
  ASTNode parse() {
    try {
      return _statement();
    } on EngineError {
      rethrow;
    } catch (e) {
      logger.error('Parser failure', e);
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

    if (_match(TokenType.store)) {
      final varName = _consume(
        TokenType.identifier,
        'Expected variable name after →',
      );
      return LetStatement(varName.lexeme, expression, varName.position);
    }

    // If starts with 'let', handle as let statement
    if (_current == 1 && tokens[0].type == TokenType.let) {
      _current = 0;
      _advance(); // consume 'let'
      return _letStatement();
    }

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

    while (_match(TokenType.multiply, TokenType.divide, TokenType.percent)) {
      final operator = _previous().type;
      final right = _implicitMultiplication();
      expr = BinaryExpression(expr, operator, right, expr.position);
    }

    return expr;
  }

  Expression _implicitMultiplication() {
    var expr = _power();

    while (_canImplicitMultiply()) {
      if (_check(TokenType.root)) {
        // Handle n-th root notation: [index]√[radicand]
        // Instead of multiplying, we use 'expr' as the index.
        final rootToken = _advance();

        // We parse the radicand with _power precedence to ensure
        // 3√8^2 parses 8^2 as the radicand.
        final radicand = _power();

        expr = RootExpression(radicand, expr, rootToken.position);
      } else {
        // Normal implicit multiplication: 2x, 5(3+1), (a)(b)
        final right = _power();
        expr = BinaryExpression(expr, TokenType.multiply, right, expr.position);
      }
    }

    return expr;
  }

  bool _canImplicitMultiply() {
    if (_isAtEnd() || _current == 0) return false;

    final current = _peek().type;
    final previous = tokens[_current - 1].type;

    // Tokens that "end" an expression and allow something to be multiplied behind them
    final validLeft = {
      TokenType.number,
      TokenType.identifier,
      TokenType.imaginaryUnit,
      TokenType.rightParen,
      TokenType.rightBracket,
      TokenType.factorial,
    };

    // Tokens that "start" a new term and trigger multiplication when following a 'left' token
    final validRight = {
      TokenType.leftParen,
      TokenType.leftBracket,
      TokenType.identifier,
      TokenType.imaginaryUnit, // Added this for number * i
      TokenType.root,
    };

    // 1. Check standard cases (e.g., 2x, 2(x), (x)y, 2i)
    if (validLeft.contains(previous) && validRight.contains(current)) {
      return true;
    }

    // 2. Handle specific edge cases: e.g., "5! 2" -> 5! * 2
    // We treat a number following a factorial as implicit multiplication
    if (previous == TokenType.factorial && current == TokenType.number) {
      return true;
    }

    return false;
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
      } else if (_check(TokenType.percent) && _canApplyUnaryPercent()) {
        _advance();
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

      // When parsing a root directly (not via implicit multiplication),
      // the index is null (defaults to square root).
      // We call _unary() for the radicand to support √√16 or √-4.
      final radicand = _unary();

      return RootExpression(radicand, null, rootPos);
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

    // FIX: Handle imaginary unit properly
    if (_match(TokenType.imaginaryUnit)) {
      final token = _previous();
      // Return an identifier 'i' instead of NumberLiteral(0)
      // This will be resolved by the binder to the complex constant
      return IdentifierExpression('i', token.position);
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
    final startPos = _previous().position;

    // Empty bracket case: []
    if (_peek().type == TokenType.rightBracket) {
      _advance();
      return VectorLiteral([], startPos);
    }

    // Check if this is a nested bracket syntax (matrix) or flat syntax (vector/matrix)
    // If the first element is a '[', it's nested bracket syntax: [[1,2],[3,4]]
    if (_check(TokenType.leftBracket)) {
      return _parseNestedBracketMatrix(startPos);
    }

    // Otherwise, it's either a vector [1,2,3] or semicolon matrix [1,2; 3,4]
    return _parseFlatBracketSyntax(startPos);
  }

  /// Parse nested bracket matrix syntax: [[1,2],[3,4]]
  Expression _parseNestedBracketMatrix(int startPos) {
    final rows = <List<Expression>>[];

    do {
      // Expect a '[' for each row
      _consume(TokenType.leftBracket, 'Expected [ for matrix row');

      final rowElements = <Expression>[];

      // Parse elements in this row
      if (!_check(TokenType.rightBracket)) {
        do {
          rowElements.add(_expression());
        } while (_match(TokenType.comma));
      }

      _consume(TokenType.rightBracket, 'Expected ] to close matrix row');
      rows.add(rowElements);
    } while (_match(TokenType.comma));

    _consume(TokenType.rightBracket, 'Expected ] to close matrix');

    // If only one row, it's still a matrix (not a vector) since it used nested syntax
    if (rows.isEmpty) {
      return MatrixLiteral([], startPos);
    }

    return MatrixLiteral(rows, startPos);
  }

  /// Parse flat bracket syntax: [1,2,3] or [1,2; 3,4]
  Expression _parseFlatBracketSyntax(int startPos) {
    final rows = <List<Expression>>[];
    var currentRow = <Expression>[];

    do {
      currentRow.add(_expression());

      if (_match(TokenType.semicolon)) {
        // Semicolon indicates a new row
        rows.add(currentRow);
        currentRow = <Expression>[];
      } else if (_match(TokenType.comma)) {
        // Comma continues the current row
        continue;
      }
    } while (!_check(TokenType.rightBracket));

    _consume(TokenType.rightBracket, 'Expected ]');

    // Add the last row if it has elements
    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    // Determine if it's a matrix or vector
    if (rows.length == 1) {
      // Single row = vector
      return VectorLiteral(rows[0], startPos);
    } else {
      // Multiple rows = matrix
      return MatrixLiteral(rows, startPos);
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

  bool _canApplyUnaryPercent() {
    if (_current + 1 >= tokens.length) return true;

    // Unary percentage is terminal/postfix: 50%, 50%+1, (x)%.
    // If the next token can start an expression (number, identifier, (, [ ...),
    // this '%' should be interpreted as binary modulo instead.
    final next = tokens[_current + 1].type;
    const binaryFollowers = {
      TokenType.number,
      TokenType.identifier,
      TokenType.leftParen,
      TokenType.leftBracket,
      TokenType.leftBrace,
      TokenType.imaginaryUnit,
      TokenType.root,
      TokenType.plus,
      TokenType.minus,
    };

    return !binaryFollowers.contains(next);
  }
}
