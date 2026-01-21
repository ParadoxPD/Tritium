import 'package:app/core/engine/parser/token.dart';

/// Base class for all AST nodes
sealed class ASTNode {
  final int position;
  const ASTNode(this.position);
}

// Expressions
sealed class Expression extends ASTNode {
  const Expression(super.position);
}

class NumberLiteral extends Expression {
  final double value;
  const NumberLiteral(this.value, int position) : super(position);
}

class StringLiteral extends Expression {
  final String value;
  const StringLiteral(this.value, int position) : super(position);
}

class IdentifierExpression extends Expression {
  final String name;
  const IdentifierExpression(this.name, int position) : super(position);
}

class BinaryExpression extends Expression {
  final Expression left;
  final TokenType operator;
  final Expression right;

  const BinaryExpression(this.left, this.operator, this.right, int position)
    : super(position);
}

class UnaryExpression extends Expression {
  final TokenType operator;
  final Expression operand;

  const UnaryExpression(this.operator, this.operand, int position)
    : super(position);
}

class CallExpression extends Expression {
  final String functionName;
  final List<Expression> arguments;

  const CallExpression(this.functionName, this.arguments, int position)
    : super(position);
}

class RootExpression extends Expression {
  final Expression? index;
  final Expression radicand;

  // FIX: position is now passed explicitly to super
  const RootExpression(this.radicand, this.index, int position)
    : super(position);
}

class MatrixLiteral extends Expression {
  final List<List<Expression>> rows;
  const MatrixLiteral(this.rows, int position) : super(position);
}

class VectorLiteral extends Expression {
  final List<Expression> components;
  const VectorLiteral(this.components, int position) : super(position);
}

class RecordLiteral extends Expression {
  final Map<String, Expression> fields;
  const RecordLiteral(this.fields, int position) : super(position);
}

class ListLiteral extends Expression {
  final List<Expression> elements;
  const ListLiteral(this.elements, int position) : super(position);
}

class IfExpression extends Expression {
  final Expression condition;
  final Expression thenBranch;
  final Expression elseBranch;

  const IfExpression(
    this.condition,
    this.thenBranch,
    this.elseBranch,
    int position,
  ) : super(position);
}

// Statements
sealed class Statement extends ASTNode {
  const Statement(super.position);
}

class ExpressionStatement extends Statement {
  final Expression expression;
  // FIX: explicit position parameter
  const ExpressionStatement(this.expression, int position) : super(position);
}

class LetStatement extends Statement {
  final String name;
  final Expression value;

  const LetStatement(this.name, this.value, int position) : super(position);
}

class FunctionDeclaration extends Statement {
  final String name;
  final List<String> parameters;
  final Expression body;

  const FunctionDeclaration(this.name, this.parameters, this.body, int position)
    : super(position);
}
