// ============================================================================
// FILE: core/engine/binder/bound_ast.dart
// Bound AST nodes (after type checking and symbol resolution)
// ============================================================================

import 'package:app/core/engine/binder/symbol_table.dart';

/// Bound nodes have resolved types and symbols
sealed class BoundNode {
  final ValueType type;
  final int position;

  const BoundNode(this.type, this.position);
}

sealed class BoundExpression extends BoundNode {
  const BoundExpression(super.type, super.position);
}

class BoundNumberLiteral extends BoundExpression {
  final double value;

  const BoundNumberLiteral(this.value, int position)
    : super(ValueType.number, position);
}

class BoundStringLiteral extends BoundExpression {
  final String value;

  const BoundStringLiteral(this.value, int position)
    : super(ValueType.string, position);
}

class BoundVariable extends BoundExpression {
  final String name;

  const BoundVariable(this.name, ValueType type, int position)
    : super(type, position);
}

class BoundBinaryOperation extends BoundExpression {
  final BoundExpression left;
  final BoundBinaryOperator operator;
  final BoundExpression right;

  const BoundBinaryOperation(
    this.left,
    this.operator,
    this.right,
    ValueType resultType,
    int position,
  ) : super(resultType, position);
}

enum BoundBinaryOperator {
  add,
  subtract,
  multiply,
  divide,
  power,
  modulo,
  equals,
  notEquals,
  lessThan,
  greaterThan,
  lessOrEqual,
  greaterOrEqual,
}

class BoundUnaryOperation extends BoundExpression {
  final BoundUnaryOperator operator;
  final BoundExpression operand;

  const BoundUnaryOperation(
    this.operator,
    this.operand,
    ValueType resultType,
    int position,
  ) : super(resultType, position);
}

enum BoundUnaryOperator { negate, factorial, absoluteValue, not, percent }

class BoundFunctionCall extends BoundExpression {
  final String functionName;
  final List<BoundExpression> arguments;

  const BoundFunctionCall(
    this.functionName,
    this.arguments,
    ValueType resultType,
    int position,
  ) : super(resultType, position);
}

class BoundRoot extends BoundExpression {
  final BoundExpression? index;
  final BoundExpression radicand;

  const BoundRoot(this.radicand, this.index, int position)
    : super(ValueType.any, position);
}

class BoundMatrixLiteral extends BoundExpression {
  final List<List<BoundExpression>> rows;

  const BoundMatrixLiteral(this.rows, int position)
    : super(ValueType.matrix, position);
}

class BoundVectorLiteral extends BoundExpression {
  final List<BoundExpression> components;

  const BoundVectorLiteral(this.components, int position)
    : super(ValueType.vector, position);
}

class BoundRecordLiteral extends BoundExpression {
  final Map<String, BoundExpression> fields;

  const BoundRecordLiteral(this.fields, int position)
    : super(ValueType.record, position);
}

class BoundListLiteral extends BoundExpression {
  final List<BoundExpression> elements;

  const BoundListLiteral(this.elements, int position)
    : super(ValueType.list, position);
}

class BoundIfExpression extends BoundExpression {
  final BoundExpression condition;
  final BoundExpression thenBranch;
  final BoundExpression elseBranch;

  const BoundIfExpression(
    this.condition,
    this.thenBranch,
    this.elseBranch,
    ValueType resultType,
    int position,
  ) : super(resultType, position);
}

sealed class BoundStatement extends BoundNode {
  const BoundStatement(super.type, super.position);
}

class BoundExpressionStatement extends BoundStatement {
  final BoundExpression expression;

  const BoundExpressionStatement(this.expression, ValueType type, int position)
    : super(type, position);
}

class BoundLetStatement extends BoundStatement {
  final String name;
  final BoundExpression value;

  const BoundLetStatement(this.name, this.value, ValueType type, int position)
    : super(type, position);
}
