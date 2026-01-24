// ============================================================================
// FILE: core/engine/evaluator/evaluator.dart
// Evaluates Bound AST to produce Values
// ============================================================================

import 'dart:math' as math;

import 'package:app/core/engine/binder/bound_ast.dart';
import 'package:app/core/engine/evaluator/runtime_errors.dart';
import 'package:app/core/engine/library/standard_library.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';

class Evaluator {
  final Map<String, Value> _variables = {};
  final Map<String, NativeFunction> _builtins = StandardLibrary.allFunctions;

  EvalContext? _currentContext;

  Evaluator() {
    _variables['Ans'] = NumberValue(0);
  }

  Value evaluate(BoundNode node, [EvalContext? context]) {
    _currentContext = context;

    if (node is BoundExpression) {
      return _evaluateExpression(node);
    } else if (node is BoundStatement) {
      return _evaluateStatement(node);
    }
    throw RuntimeError('Unknown bound node type: ${node.runtimeType}');
  }

  void setVariable(String name, Value value) {
    _variables[name] = value;
  }

  // ADDED: Required by Engine.getVariable()
  Value? getVariable(String name) {
    return _variables[name];
  }

  // ADDED: Required by Engine.clearVariables()
  void clearUserVariables() {
    _variables.clear();
  }

  Value _evaluateExpression(BoundExpression expr) {
    switch (expr) {
      case BoundNumberLiteral():
        return NumberValue(expr.value);

      case BoundStringLiteral():
        return StringValue(expr.value);

      case BoundVariable():
        final value = _variables[expr.name];
        if (value == null) {
          throw RuntimeError('Undefined variable: ${expr.name}');
        }
        return value;

      case BoundBinaryOperation():
        return _evaluateBinaryOp(expr);

      case BoundUnaryOperation():
        return _evaluateUnaryOp(expr);

      case BoundFunctionCall():
        return _evaluateFunctionCall(expr);

      case BoundRoot():
        return _evaluateRoot(expr);

      case BoundMatrixLiteral():
        return _evaluateMatrix(expr);

      case BoundVectorLiteral():
        return _evaluateVector(expr);

      case BoundRecordLiteral():
        return _evaluateRecord(expr);

      case BoundListLiteral():
        final elements = expr.elements.map(_evaluateExpression).toList();
        return ListValue(elements);

      case BoundIfExpression():
        final condition = _evaluateExpression(expr.condition);
        if (_isTruthy(condition)) {
          return _evaluateExpression(expr.thenBranch);
        } else {
          return _evaluateExpression(expr.elseBranch);
        }

      default:
        throw RuntimeError('Unknown expression type: ${expr.runtimeType}');
    }
  }

  Value _evaluateStatement(BoundStatement stmt) {
    switch (stmt) {
      case BoundExpressionStatement():
        return _evaluateExpression(stmt.expression);

      case BoundLetStatement():
        final value = _evaluateExpression(stmt.value);
        _variables[stmt.name] = value;
        return value;

      default:
        throw RuntimeError('Unknown statement type: ${stmt.runtimeType}');
    }
  }

  Value _evaluateBinaryOp(BoundBinaryOperation op) {
    final left = _evaluateExpression(op.left);
    final right = _evaluateExpression(op.right);

    return switch (op.operator) {
      BoundBinaryOperator.add => _add(left, right),
      BoundBinaryOperator.subtract => _subtract(left, right),
      BoundBinaryOperator.multiply => _multiply(left, right),
      BoundBinaryOperator.divide => _divide(left, right),
      BoundBinaryOperator.power => _power(left, right),
      BoundBinaryOperator.modulo => _modulo(left, right),
      BoundBinaryOperator.equals => BooleanValue(_equals(left, right)),
      BoundBinaryOperator.notEquals => BooleanValue(!_equals(left, right)),
      BoundBinaryOperator.lessThan => _compare(left, right, (a, b) => a < b),
      BoundBinaryOperator.greaterThan => _compare(left, right, (a, b) => a > b),
      BoundBinaryOperator.lessOrEqual => _compare(
        left,
        right,
        (a, b) => a <= b,
      ),
      BoundBinaryOperator.greaterOrEqual => _compare(
        left,
        right,
        (a, b) => a >= b,
      ),
    };
  }

  Value _add(Value a, Value b) {
    if (a is NumberValue && b is NumberValue)
      return NumberValue(a.value + b.value);
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      return ComplexValue(ca.real + cb.real, ca.imaginary + cb.imaginary);
    }
    if (a is MatrixValue && b is MatrixValue) return _addMatrices(a, b);
    if (a is VectorValue && b is VectorValue) return _addVectors(a, b);
    throw RuntimeError('Cannot add ${a.runtimeType} and ${b.runtimeType}');
  }

  Value _subtract(Value a, Value b) {
    if (a is NumberValue && b is NumberValue)
      return NumberValue(a.value - b.value);
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      return ComplexValue(ca.real - cb.real, ca.imaginary - cb.imaginary);
    }
    throw RuntimeError('Cannot subtract ${a.runtimeType} and ${b.runtimeType}');
  }

  Value _multiply(Value a, Value b) {
    if (a is NumberValue && b is NumberValue)
      return NumberValue(a.value * b.value);
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      return ComplexValue(
        ca.real * cb.real - ca.imaginary * cb.imaginary,
        ca.real * cb.imaginary + ca.imaginary * cb.real,
      );
    }
    if (a is MatrixValue && b is MatrixValue) return _multiplyMatrices(a, b);
    throw RuntimeError('Cannot multiply ${a.runtimeType} and ${b.runtimeType}');
  }

  Value _divide(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      if (b.value == 0) throw RuntimeError('Division by zero');
      return NumberValue(a.value / b.value);
    }
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      final denom = cb.real * cb.real + cb.imaginary * cb.imaginary;
      return ComplexValue(
        (ca.real * cb.real + ca.imaginary * cb.imaginary) / denom,
        (ca.imaginary * cb.real - ca.real * cb.imaginary) / denom,
      );
    }
    throw RuntimeError('Cannot divide ${a.runtimeType} by ${b.runtimeType}');
  }

  Value _power(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      return NumberValue(math.pow(a.value, b.value).toDouble());
    }
    throw RuntimeError(
      'Cannot raise ${a.runtimeType} to power of ${b.runtimeType}',
    );
  }

  Value _modulo(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      return NumberValue(a.value % b.value);
    }
    throw RuntimeError(
      'Cannot take modulo of ${a.runtimeType} and ${b.runtimeType}',
    );
  }

  Value _evaluateUnaryOp(BoundUnaryOperation op) {
    final operand = _evaluateExpression(op.operand);
    return switch (op.operator) {
      BoundUnaryOperator.negate => _negate(operand),
      BoundUnaryOperator.factorial => _factorial(operand),
      BoundUnaryOperator.absoluteValue => _absolute(operand),
      BoundUnaryOperator.not => BooleanValue(!_isTruthy(operand)),
      BoundUnaryOperator.percent => _percent(operand),
    };
  }

  Value _percent(Value v) {
    if (v is NumberValue) return NumberValue(v.value / 100.0);
    throw RuntimeError('Percentage requires a number');
  }

  Value _negate(Value v) {
    if (v is NumberValue) return NumberValue(-v.value);
    if (v is ComplexValue) return ComplexValue(-v.real, -v.imaginary);
    throw RuntimeError('Cannot negate ${v.runtimeType}');
  }

  Value _factorial(Value v) {
    if (v is! NumberValue) throw RuntimeError('Factorial requires a number');
    final n = v.value.toInt();
    if (n < 0 || n != v.value)
      throw RuntimeError('Factorial requires non-negative integer');

    int result = 1;
    for (int i = 2; i <= n; i++) result *= i;
    return NumberValue(result.toDouble());
  }

  Value _absolute(Value v) {
    if (v is NumberValue) return NumberValue(v.value.abs());
    if (v is ComplexValue) {
      final mag = math.sqrt(v.real * v.real + v.imaginary * v.imaginary);
      return NumberValue(mag);
    }
    throw RuntimeError('Cannot take absolute value of ${v.runtimeType}');
  }

  Value _evaluateFunctionCall(BoundFunctionCall call) {
    final fn = _builtins[call.functionName];
    if (fn == null) {
      throw RuntimeError('Unknown function: ${call.functionName}');
    }

    final args = call.arguments.map(_evaluateExpression).toList();
    if (args.length != fn.arity) {
      throw RuntimeError(
        '${call.functionName} expects ${fn.arity} arguments, got ${args.length}',
      );
    }

    return fn.execute(args);
  }

  Value _evaluateRoot(BoundRoot root) {
    final radicand = _evaluateExpression(root.radicand);
    final index = root.index != null
        ? _evaluateExpression(root.index!) as NumberValue
        : NumberValue(2);

    if (radicand is! NumberValue) {
      throw RuntimeError('Root requires numeric radicand');
    }

    final n = index.value;
    final x = radicand.value;

    if (n == 0) throw RuntimeError('0th root is undefined');

    if (x < 0 && n % 2 == 0) {
      return ComplexValue(0, math.pow(x.abs(), 1 / n).toDouble());
    }

    return NumberValue(math.pow(x, 1 / n).toDouble());
  }

  Value _evaluateMatrix(BoundMatrixLiteral mat) {
    final data = mat.rows.map((row) {
      return row.map((e) {
        final v = _evaluateExpression(e);
        if (v is! NumberValue)
          throw RuntimeError('Matrix elements must be numbers');
        return v.value;
      }).toList();
    }).toList();
    return MatrixValue(data);
  }

  Value _evaluateVector(BoundVectorLiteral vec) {
    final components = vec.components.map((e) {
      final v = _evaluateExpression(e);
      if (v is! NumberValue)
        throw RuntimeError('Vector components must be numbers');
      return v.value;
    }).toList();
    return VectorValue(components);
  }

  Value _evaluateRecord(BoundRecordLiteral rec) {
    final fields = rec.fields.map(
      (key, value) => MapEntry(key, _evaluateExpression(value)),
    );
    return RecordValue(fields);
  }

  // ... (Matrix/Vector/Complex helpers _toComplex, _addMatrices, etc. remain unchanged) ...
  ComplexValue _toComplex(Value v) {
    if (v is ComplexValue) return v;
    if (v is NumberValue) return ComplexValue(v.value, 0);
    throw RuntimeError('Cannot convert ${v.runtimeType} to complex');
  }

  MatrixValue _addMatrices(MatrixValue a, MatrixValue b) {
    if (a.rows != b.rows || a.cols != b.cols) {
      throw RuntimeError('Matrix dimensions must match for addition');
    }
    final result = List.generate(
      a.rows,
      (i) => List.generate(a.cols, (j) => a.data[i][j] + b.data[i][j]),
    );
    return MatrixValue(result);
  }

  VectorValue _addVectors(VectorValue a, VectorValue b) {
    if (a.dimension != b.dimension) {
      throw RuntimeError('Vector dimensions must match');
    }
    final result = List.generate(
      a.dimension,
      (i) => a.components[i] + b.components[i],
    );
    return VectorValue(result);
  }

  MatrixValue _multiplyMatrices(MatrixValue a, MatrixValue b) {
    if (a.cols != b.rows) {
      throw RuntimeError('Invalid matrix dimensions for multiplication');
    }
    final result = List.generate(a.rows, (i) {
      return List.generate(b.cols, (j) {
        double sum = 0;
        for (int k = 0; k < a.cols; k++) {
          sum += a.data[i][k] * b.data[k][j];
        }
        return sum;
      });
    });
    return MatrixValue(result);
  }

  bool _equals(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) return a.value == b.value;
    if (a is BooleanValue && b is BooleanValue) return a.value == b.value;
    if (a is StringValue && b is StringValue) return a.value == b.value;
    return false;
  }

  BooleanValue _compare(Value a, Value b, bool Function(double, double) op) {
    if (a is! NumberValue || b is! NumberValue) {
      throw RuntimeError('Comparison requires numbers');
    }
    return BooleanValue(op(a.value, b.value));
  }

  bool _isTruthy(Value v) {
    if (v is BooleanValue) return v.value;
    if (v is NumberValue) return v.value != 0;
    return true;
  }
}

class NativeFunction {
  final int arity;
  final Value Function(List<Value>) execute;

  const NativeFunction(this.arity, this.execute);
}
