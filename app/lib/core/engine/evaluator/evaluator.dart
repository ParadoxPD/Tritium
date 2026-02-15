// ============================================================================
// FILE: core/engine/evaluator/evaluator.dart
// Updated to pass context to native functions
// ============================================================================

import 'dart:math' as math;
import 'dart:math';

import 'package:app/core/engine/binder/bound_ast.dart';
import 'package:app/core/engine/evaluator/runtime_errors.dart';
import 'package:app/core/engine/library/standard_library.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';

class Evaluator {
  final Map<String, Value> _variables = {};
  final Map<String, NativeFunction> _builtins = StandardLibrary.allFunctions;

  EvalContext? _currentContext;

  Evaluator() {
    _variables['Ans'] = NumberValue(0);
    StandardLibrary.allConstants.forEach((name, value) {
      _variables[name] = value;
    });
  }

  Value evaluate(BoundNode node, [EvalContext? context]) {
    _currentContext = context;

    if (node is BoundExpression) {
      return _evaluateExpression(node);
    } else if (node is BoundStatement) {
      return _evaluateStatement(node);
    }
    throw RuntimeError(
      message: 'Unknown bound node type: ${node.runtimeType}',
      type: ErrorType.unknown,
    );
  }

  void setVariable(String name, Value value) {
    _variables[name] = value;
  }

  Value? getVariable(String name) {
    return _variables[name];
  }

  void clearUserVariables() {
    _variables.clear();

    // Re-initialize Ans
    _variables['Ans'] = NumberValue(0);

    // Re-initialize all standard library constants
    StandardLibrary.allConstants.forEach((name, value) {
      _variables[name] = value;
    });
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
          throw RuntimeError(
            message: 'Undefined variable: ${expr.name}',
            type: ErrorType.undefinedVariable,
            position: expr.position,
          );
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
    if (a is NumberValue && b is NumberValue) {
      return NumberValue(a.value + b.value);
    }
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      return ComplexValue(ca.real + cb.real, ca.imaginary + cb.imaginary);
    }
    if (a is MatrixValue && b is MatrixValue) return _addMatrices(a, b);
    if (a is VectorValue && b is VectorValue) return _addVectors(a, b);
    throw RuntimeError(
      message: 'Cannot add ${a.runtimeType} and ${b.runtimeType}',
      type: ErrorType.typeMismatch,
    );
  }

  Value _subtract(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      return NumberValue(a.value - b.value);
    }
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      return ComplexValue(ca.real - cb.real, ca.imaginary - cb.imaginary);
    }
    if (a is MatrixValue && b is MatrixValue) return _subtractMatrices(a, b);
    throw RuntimeError(
      message: 'Cannot subtract ${a.runtimeType} and ${b.runtimeType}',
      type: ErrorType.typeMismatch,
    );
  }

  Value _multiply(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      return NumberValue(a.value * b.value);
    }
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      return ComplexValue(
        ca.real * cb.real - ca.imaginary * cb.imaginary,
        ca.real * cb.imaginary + ca.imaginary * cb.real,
      );
    }
    if (a is NumberValue && b is MatrixValue) {
      return _scalarMultiply(b, a.value);
    }
    if (a is MatrixValue && b is NumberValue) {
      return _scalarMultiply(a, b.value);
    }

    if (a is MatrixValue && b is MatrixValue) return _multiplyMatrices(a, b);
    throw RuntimeError(
      message: 'Cannot multiply ${a.runtimeType} and ${b.runtimeType}',
      type: ErrorType.typeMismatch,
    );
  }

  Value _divide(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      if (b.value == 0) {
        throw RuntimeError(
          message: 'Division by zero',
          type: ErrorType.divisionByZero,
        );
      }
      return NumberValue(a.value / b.value);
    }
    if (a is ComplexValue || b is ComplexValue) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      final denom = cb.real * cb.real + cb.imaginary * cb.imaginary;
      if (denom == 0) {
        throw RuntimeError(
          message: 'Division by zero complex number',
          type: ErrorType.divisionByZero,
        );
      }
      return ComplexValue(
        (ca.real * cb.real + ca.imaginary * cb.imaginary) / denom,
        (ca.imaginary * cb.real - ca.real * cb.imaginary) / denom,
      );
    }
    throw RuntimeError(
      message: 'Cannot divide ${a.runtimeType} by ${b.runtimeType}',
      type: ErrorType.typeMismatch,
    );
  }

  Value _power(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      return NumberValue(math.pow(a.value, b.value).toDouble());
    }
    throw RuntimeError(
      message: 'Cannot raise ${a.runtimeType} to power of ${b.runtimeType}',
      type: ErrorType.typeMismatch,
    );
  }

  Value _modulo(Value a, Value b) {
    if (a is NumberValue && b is NumberValue) {
      if (b.value == 0) {
        throw RuntimeError(
          message: 'Modulo by zero is undefined',
          type: ErrorType.divisionByZero,
          hint: 'Use a non-zero modulus.',
        );
      }
      final modulus = b.value.abs();
      final remainder = ((a.value % modulus) + modulus) % modulus;
      return NumberValue(remainder);
    }
    throw RuntimeError(
      message: 'Cannot take modulo of ${a.runtimeType} and ${b.runtimeType}',
      type: ErrorType.typeMismatch,
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
    throw RuntimeError(
      message: 'Percentage requires a number',
      type: ErrorType.typeMismatch,
    );
  }

  Value _negate(Value v) {
    if (v is NumberValue) return NumberValue(-v.value);
    if (v is ComplexValue) return ComplexValue(-v.real, -v.imaginary);
    throw RuntimeError(
      message: 'Cannot negate ${v.runtimeType}',
      type: ErrorType.typeMismatch,
    );
  }

  Value _factorial(Value v) {
    if (v is! NumberValue) {
      throw RuntimeError(
        message: 'Factorial requires a number',
        type: ErrorType.typeMismatch,
      );
    }
    final n = v.value.toInt();
    if (n < 0) {
      throw RuntimeError(
        message: 'Factorial requires non-negative integer',
        type: ErrorType.domainError,
      );
    }

    if (n == v.value) {
      if (n <= 20) {
        int r = 1;
        for (int i = 2; i <= n; i++) {
          r *= i;
        }
        return NumberValue(r.toDouble());
      }
    }

    double logSum = n * (log(n / e) / ln10) + 0.5 * (log(2 * pi * n) / ln10);

    final exponent = logSum.floor();
    final mantissa = pow(10, logSum - exponent);

    return NumberValueSci(mantissa.toDouble(), exponent);
  }

  Value _absolute(Value v) {
    if (v is NumberValue) return NumberValue(v.value.abs());
    if (v is ComplexValue) {
      final mag = math.sqrt(v.real * v.real + v.imaginary * v.imaginary);
      return NumberValue(mag);
    }
    throw RuntimeError(
      message: 'Cannot take absolute value of ${v.runtimeType}',
      type: ErrorType.typeMismatch,
    );
  }

  Value _evaluateFunctionCall(BoundFunctionCall call) {
    final fn = _builtins[call.functionName];
    if (fn == null) {
      throw RuntimeError(
        message: 'Unknown function: ${call.functionName}',
        type: ErrorType.undefinedFunction,
        position: call.position,
      );
    }

    final args = call.arguments.map(_evaluateExpression).toList();
    if (args.length != fn.arity) {
      throw RuntimeError(
        message:
            '${call.functionName} expects ${fn.arity} arguments, got ${args.length}',
        type: ErrorType.wrongArgumentCount,
        position: call.position,
      );
    }

    // Pass the current context to the function
    try {
      return fn.execute(args, _currentContext);
    } on RuntimeError {
      rethrow;
    } catch (e) {
      throw RuntimeError(
        message: 'Function ${call.functionName} failed',
        type: ErrorType.runtime,
        operation: call.functionName,
        position: call.position,
        cause: e,
      );
    }
  }

  Value _evaluateRoot(BoundRoot root) {
    final radicand = _evaluateExpression(root.radicand);
    final index = root.index != null
        ? _evaluateExpression(root.index!) as NumberValue
        : NumberValue(2);

    if (radicand is! NumberValue) {
      throw RuntimeError(
        message: 'Root requires numeric radicand',
        type: ErrorType.typeMismatch,
        position: root.position,
      );
    }

    final n = index.value;
    final x = radicand.value;

    if (n == 0) {
      throw RuntimeError(
        message: '0th root is undefined',
        type: ErrorType.domainError,
        position: root.position,
      );
    }

    if (x < 0 && n % 2 == 0) {
      return ComplexValue(0, math.pow(x.abs(), 1 / n).toDouble());
    }

    return NumberValue(math.pow(x, 1 / n).toDouble());
  }

  Value _evaluateMatrix(BoundMatrixLiteral mat) {
    final data = mat.rows.map((row) {
      return row.map((e) {
        final v = _evaluateExpression(e);
        if (v is! NumberValue) {
          throw RuntimeError(
            message: 'Matrix elements must be numbers',
            type: ErrorType.typeMismatch,
            position: e.position,
          );
        }
        return v.value;
      }).toList();
    }).toList();
    return MatrixValue(data);
  }

  Value _evaluateVector(BoundVectorLiteral vec) {
    final components = vec.components.map((e) {
      final v = _evaluateExpression(e);
      if (v is! NumberValue) {
        throw RuntimeError(
          message: 'Vector components must be numbers',
          type: ErrorType.typeMismatch,
          position: e.position,
        );
      }
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

  // Matrix/Vector/Complex helpers
  ComplexValue _toComplex(Value v) {
    if (v is ComplexValue) return v;
    if (v is NumberValue) return ComplexValue(v.value, 0);
    throw RuntimeError(
      message: 'Cannot convert ${v.runtimeType} to complex',
      type: ErrorType.typeMismatch,
    );
  }

  MatrixValue _addMatrices(MatrixValue a, MatrixValue b) {
    if (a.rows != b.rows || a.cols != b.cols) {
      throw RuntimeError(
        message: 'Matrix dimensions must match for addition',
        type: ErrorType.dimensionMismatch,
      );
    }
    final result = List.generate(
      a.rows,
      (i) => List.generate(a.cols, (j) => a.data[i][j] + b.data[i][j]),
    );
    return MatrixValue(result);
  }

  VectorValue _addVectors(VectorValue a, VectorValue b) {
    if (a.dimension != b.dimension) {
      throw RuntimeError(
        message: 'Vector dimensions must match',
        type: ErrorType.dimensionMismatch,
      );
    }
    final result = List.generate(
      a.dimension,
      (i) => a.components[i] + b.components[i],
    );
    return VectorValue(result);
  }

  MatrixValue _multiplyMatrices(MatrixValue a, MatrixValue b) {
    if (a.cols != b.rows) {
      throw RuntimeError(
        message: 'Invalid matrix dimensions for multiplication',
        type: ErrorType.dimensionMismatch,
      );
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

  MatrixValue _subtractMatrices(MatrixValue a, MatrixValue b) {
    if (a.rows != b.rows || a.cols != b.cols) {
      throw RuntimeError(
        message: 'Matrix dimensions must match for subtraction',
        type: ErrorType.dimensionMismatch,
      );
    }
    final result = List.generate(
      a.rows,
      (i) => List.generate(a.cols, (j) => a.data[i][j] - b.data[i][j]),
    );
    return MatrixValue(result);
  }

  MatrixValue _scalarMultiply(MatrixValue a, double scalar) {
    final result = List.generate(
      a.rows,
      (i) => List.generate(a.cols, (j) => a.data[i][j] * scalar),
    );
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
      throw RuntimeError(
        message: 'Comparison requires numbers',
        type: ErrorType.typeMismatch,
      );
    }
    return BooleanValue(op(a.value, b.value));
  }

  bool _isTruthy(Value v) {
    if (v is BooleanValue) return v.value;
    if (v is NumberValue) return v.value != 0;
    return true;
  }
}

// Updated NativeFunction to accept context
class NativeFunction {
  final int arity;
  final Value Function(List<Value>, EvalContext?) execute;

  const NativeFunction(this.arity, this.execute);
}
