// ============================================================================
// FILE: core/engine/binder/binder.dart
// Binds AST to typed, resolved Bound AST
// ============================================================================

import 'package:app/core/engine/binder/bound_ast.dart';
import 'package:app/core/engine/binder/symbol_table.dart';
import 'package:app/core/engine/library/standard_library.dart';
import 'package:app/core/engine/parser/ast.dart';
import 'package:app/core/engine/parser/token.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_types.dart';

class Binder {
  final SymbolTable _symbols;

  final List<EngineError> _diagnostics = [];
  List<EngineError> get diagnostics => _diagnostics;

  Binder([SymbolTable? symbols]) : _symbols = symbols ?? _createGlobalScope();

  static SymbolTable _createGlobalScope() {
    final scope = SymbolTable();

    // Load definitions dynamically from the Standard Library
    StandardLibrary.allConstants.forEach((name, val) {
      ValueType type = switch (val) {
        NumberValue() => ValueType.number,
        ComplexValue() => ValueType.complex,
        _ => ValueType.any,
      };
      scope.define(name, type, isConstant: true);
    });

    StandardLibrary.allFunctions.forEach((name, fn) {
      scope.define(name, ValueType.function, isConstant: true);
    });

    scope.define('Ans', ValueType.any);

    return scope;
  }

  void defineVariable(String name, ValueType type) {
    _symbols.define(name, type);
  }

  // ... Update _bindUnaryOperator to include percent ...
  BoundUnaryOperator _bindUnaryOperator(TokenType type) {
    return switch (type) {
      TokenType.minus => BoundUnaryOperator.negate,
      TokenType.factorial => BoundUnaryOperator.factorial,
      TokenType.percent => BoundUnaryOperator.percent,
      _ => throw ArgumentError('Invalid unary operator: $type'),
    };
  }

  BoundNode bind(ASTNode node) {
    // Clear previous diagnostics
    _diagnostics.clear();

    try {
      if (node is Expression) {
        return _bindExpression(node);
      } else if (node is Statement) {
        return _bindStatement(node);
      }
      throw EngineError(
        ErrorType.unknown,
        'Unknown node type: ${node.runtimeType}',
        position: node.position,
      );
    } catch (e) {
      // If it's an EngineError, we can record it.
      // For now, we rethrow because the current Engine structure catches exceptions,
      // but having the diagnostics list ready is good practice for future recovery.
      if (e is EngineError) {
        _diagnostics.add(e);
      }
      rethrow;
    }
  }

  BoundExpression _bindExpression(Expression expr) {
    switch (expr) {
      case NumberLiteral():
        return BoundNumberLiteral(expr.value, expr.position);

      case StringLiteral():
        return BoundStringLiteral(expr.value, expr.position);

      case IdentifierExpression():
        final symbol = _symbols.lookup(expr.name);
        if (symbol == null) {
          // Special handling for single-letter variables that might not be defined yet
          // Allow them to be used (will be defined on first assignment)
          if (expr.name.length == 1 && RegExp(r'[A-Z]').hasMatch(expr.name)) {
            // Auto-define single-letter uppercase variables
            _symbols.define(expr.name, ValueType.any);
            return BoundVariable(expr.name, ValueType.any, expr.position);
          }

          throw EngineError(
            ErrorType.undefinedVariable,
            'Undefined variable: ${expr.name}',
            position: expr.position,
            hint: 'Make sure the variable is defined before use',
          );
        }
        return BoundVariable(expr.name, symbol.type, expr.position);

      case BinaryExpression():
        final left = _bindExpression(expr.left);
        final right = _bindExpression(expr.right);
        final op = _bindBinaryOperator(expr.operator);
        final resultType = _inferBinaryType(left.type, op, right.type);
        return BoundBinaryOperation(left, op, right, resultType, expr.position);

      case UnaryExpression():
        final operand = _bindExpression(expr.operand);
        final op = _bindUnaryOperator(expr.operator);
        final resultType = _inferUnaryType(op, operand.type);
        return BoundUnaryOperation(op, operand, resultType, expr.position);

      case CallExpression():
        final args = expr.arguments.map(_bindExpression).toList();
        final symbol = _symbols.lookup(expr.functionName);
        if (symbol == null) {
          throw EngineError(
            ErrorType.undefinedFunction,
            'Undefined function: ${expr.functionName}',
            position: expr.position,
          );
        }
        return BoundFunctionCall(
          expr.functionName,
          args,
          ValueType.any,
          expr.position,
        );

      case RootExpression():
        final radicand = _bindExpression(expr.radicand);
        final index = expr.index != null ? _bindExpression(expr.index!) : null;
        return BoundRoot(radicand, index, expr.position);

      case MatrixLiteral():
        final rows = expr.rows
            .map((row) => row.map(_bindExpression).toList())
            .toList();
        return BoundMatrixLiteral(rows, expr.position);

      case VectorLiteral():
        final components = expr.components.map(_bindExpression).toList();
        return BoundVectorLiteral(components, expr.position);

      case RecordLiteral():
        final fields = expr.fields.map(
          (key, value) => MapEntry(key, _bindExpression(value)),
        );
        return BoundRecordLiteral(fields, expr.position);

      case ListLiteral():
        final elements = expr.elements.map(_bindExpression).toList();
        return BoundListLiteral(elements, expr.position);

      case IfExpression():
        final condition = _bindExpression(expr.condition);
        final thenBranch = _bindExpression(expr.thenBranch);
        final elseBranch = _bindExpression(expr.elseBranch);
        final resultType = _unifyTypes(thenBranch.type, elseBranch.type);
        return BoundIfExpression(
          condition,
          thenBranch,
          elseBranch,
          resultType,
          expr.position,
        );

      default:
        throw EngineError(
          ErrorType.unknown,
          'Unknown expression type: ${expr.runtimeType}',
          position: expr.position,
        );
    }
  }

  BoundStatement _bindStatement(Statement stmt) {
    switch (stmt) {
      case ExpressionStatement():
        BoundExpression expression = _bindExpression(stmt.expression);
        return BoundExpressionStatement(
          expression,
          expression.type,
          expression.position,
        );

      case LetStatement():
        final value = _bindExpression(stmt.value);
        _symbols.define(stmt.name, value.type);
        return BoundLetStatement(stmt.name, value, value.type, stmt.position);

      default:
        throw EngineError(
          ErrorType.unknown,
          'Unknown statement type: ${stmt.runtimeType}',
          position: stmt.position,
        );
    }
  }

  BoundBinaryOperator _bindBinaryOperator(TokenType type) {
    return switch (type) {
      TokenType.plus => BoundBinaryOperator.add,
      TokenType.minus => BoundBinaryOperator.subtract,
      TokenType.multiply => BoundBinaryOperator.multiply,
      TokenType.divide => BoundBinaryOperator.divide,
      TokenType.power => BoundBinaryOperator.power,
      TokenType.equals => BoundBinaryOperator.equals,
      TokenType.notEquals => BoundBinaryOperator.notEquals,
      TokenType.lessThan => BoundBinaryOperator.lessThan,
      TokenType.greaterThan => BoundBinaryOperator.greaterThan,
      TokenType.lessOrEqual => BoundBinaryOperator.lessOrEqual,
      TokenType.greaterOrEqual => BoundBinaryOperator.greaterOrEqual,
      _ => throw ArgumentError('Invalid binary operator: $type'),
    };
  }

  ValueType _inferBinaryType(
    ValueType left,
    BoundBinaryOperator op,
    ValueType right,
  ) {
    if (op == BoundBinaryOperator.add || op == BoundBinaryOperator.subtract) {
      if (left == ValueType.matrix && right == ValueType.matrix) {
        return ValueType.matrix;
      }
      if (left == ValueType.vector && right == ValueType.vector) {
        return ValueType.vector;
      }
      if (left == ValueType.complex || right == ValueType.complex) {
        return ValueType.complex;
      }
      return ValueType.number;
    }
    return ValueType.number;
  }

  ValueType _inferUnaryType(BoundUnaryOperator op, ValueType operandType) =>
      operandType;

  ValueType _unifyTypes(ValueType a, ValueType b) {
    if (a == b) return a;
    if (a == ValueType.any || b == ValueType.any) return ValueType.any;
    return ValueType.any;
  }
}
