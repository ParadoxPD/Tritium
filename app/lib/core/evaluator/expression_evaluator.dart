import 'dart:math' as math;
import 'package:app/core/evaluator/eval_context.dart';
import 'package:app/core/evaluator/eval_types.dart';

class ExpressionEvaluator {
  final Map<String, EvalSuccess> _cache = {};

  EvaluationResult evaluate(
    String expr,
    AngleMode mode, {
    EvalContext context = const EvalContext(),
    RecursionGuard guard = const RecursionGuard(0, 32),
  }) {
    try {
      // Cache key
      final key = '$expr|$mode|${context.baseMode}|${context.exactMode}';
      if (_cache.containsKey(key)) {
        return _cache[key]!;
      }

      // Handle base-N literals
      if (context.baseMode != BaseMode.decimal) {
        expr = _convertBaseNLiterals(expr);
      }

      final tokens = _insertImplicitMultiplication(_tokenize(expr, context));
      final postfix = _toPostfix(tokens, context);
      final result = _evalPostfix(postfix, mode, context, guard);

      final success = EvalSuccess(
        result is double ? result : (result as Matrix).data[0][0],
        fraction: context.exactMode && result is double
            ? Fraction.fromDouble(result)
            : null,
        matrix: result is Matrix ? result : null,
      );

      _cache[key] = success;
      return success;
    } on EvalError catch (e) {
      return e;
    } catch (e) {
      return EvalError(EvalErrorType.unknown, 'Error: $e');
    }
  }

  String _convertBaseNLiterals(String expr) {
    // Convert 0b, 0o, 0x literals to decimal
    expr = expr.replaceAllMapped(RegExp(r'0b([01]+)'), (m) {
      return int.parse(m.group(1)!, radix: 2).toString();
    });
    expr = expr.replaceAllMapped(RegExp(r'0o([0-7]+)'), (m) {
      return int.parse(m.group(1)!, radix: 8).toString();
    });
    expr = expr.replaceAllMapped(RegExp(r'0x([0-9A-Fa-f]+)'), (m) {
      return int.parse(m.group(1)!, radix: 16).toString();
    });
    return expr;
  }

  // ===================== TOKENIZER =====================

  List<String> _tokenize(String expr, EvalContext context) {
    // Replace constants
    expr = expr
        .replaceAll('π', math.pi.toString())
        .replaceAllMapped(
          RegExp(r'(?<![\w.])e(?![\w.])'),
          (_) => math.e.toString(),
        )
        .replaceAll('i', '__I__'); // Complex unit marker

    final tokens = <String>[];
    final buf = StringBuffer();

    void flush() {
      if (buf.isNotEmpty) {
        tokens.add(buf.toString());
        buf.clear();
      }
    }

    for (int i = 0; i < expr.length; i++) {
      final c = expr[i];

      if ('0123456789.'.contains(c)) {
        buf.write(c);
      } else {
        flush();
        if (c.trim().isEmpty) continue;

        // Special characters
        if (c == ',') {
          tokens.add(',');
          continue;
        }
        if (c == '!') {
          tokens.add('!');
          continue;
        }
        if (c == '[') {
          tokens.add('[');
          continue;
        }
        if (c == ']') {
          tokens.add(']');
          continue;
        }
        if (c == ';') {
          // Matrix row separator
          tokens.add(';');
          continue;
        }

        // Operators and parentheses
        if ('+-*/^()'.contains(c)) {
          if ((c == '-' || c == '+') &&
              (tokens.isEmpty || '()+-*/^,[;'.contains(tokens.last))) {
            tokens.add(c == '-' ? 'u-' : 'u+');
          } else {
            tokens.add(c);
          }
        } else {
          // Function or identifier
          buf.write(c);
          while (i + 1 < expr.length &&
              RegExp(r'[a-zA-Z_0-9]').hasMatch(expr[i + 1])) {
            buf.write(expr[++i]);
          }
          tokens.add(buf.toString());
          buf.clear();
        }
      }
    }
    flush();
    return tokens;
  }

  // ===================== IMPLICIT MULTIPLICATION =====================

  List<String> _insertImplicitMultiplication(List<String> t) {
    final out = <String>[];
    bool isValue(String x) =>
        _isNumber(x) || x == ')' || x == ']' || x == '__I__';
    bool isStart(String x) =>
        _isNumber(x) || x == '(' || x == '[' || _isFunction(x) || x == '__I__';

    for (int i = 0; i < t.length; i++) {
      out.add(t[i]);
      if (i == t.length - 1) break;

      final a = t[i];
      final b = t[i + 1];

      if (isValue(a) && isStart(b)) {
        out.add('*');
      }
    }
    return out;
  }

  // ===================== SHUNTING YARD =====================

  List<String> _toPostfix(List<String> tokens, EvalContext context) {
    final out = <String>[];
    final stack = <String>[];

    final prec = {
      '!': 6,
      'u+': 5,
      'u-': 5,
      '^': 4,
      '*': 3,
      '/': 3,
      '+': 2,
      '-': 2,
    };

    final rightAssoc = {'^', 'u-', 'u+'};

    for (final tok in tokens) {
      if (_isNumber(tok)) {
        out.add(tok);
      } else if (tok == '__I__') {
        out.add(tok);
      } else if (_isFunction(tok) || _isMatrixFunction(tok)) {
        stack.add(tok);
      } else if (tok == '(' || tok == '[') {
        stack.add(tok);
      } else if (tok == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          out.add(stack.removeLast());
        }
        if (stack.isEmpty) {
          throw const EvalError(EvalErrorType.syntax, 'Mismatched parentheses');
        }
        stack.removeLast();
        if (stack.isNotEmpty && _isFunction(stack.last)) {
          out.add(stack.removeLast());
        }
      } else if (tok == ']') {
        while (stack.isNotEmpty && stack.last != '[') {
          out.add(stack.removeLast());
        }
        if (stack.isEmpty) {
          throw const EvalError(EvalErrorType.syntax, 'Mismatched brackets');
        }
        stack.removeLast();
        if (stack.isNotEmpty && _isMatrixFunction(stack.last)) {
          out.add(stack.removeLast());
        }
      } else if (tok == ',' || tok == ';') {
        while (stack.isNotEmpty && stack.last != '(' && stack.last != '[') {
          out.add(stack.removeLast());
        }
        out.add(tok); // Keep separator in output for matrix parsing
      } else {
        while (stack.isNotEmpty &&
            prec.containsKey(stack.last) &&
            (rightAssoc.contains(tok)
                ? prec[stack.last]! > prec[tok]!
                : prec[stack.last]! >= prec[tok]!)) {
          out.add(stack.removeLast());
        }
        stack.add(tok);
      }
    }

    while (stack.isNotEmpty) {
      if (stack.last == '(' || stack.last == '[') {
        throw const EvalError(EvalErrorType.syntax, 'Mismatched parentheses');
      }
      out.add(stack.removeLast());
    }
    return out;
  }

  // ===================== POSTFIX EVALUATION =====================

  dynamic _evalPostfix(
    List<String> t,
    AngleMode mode,
    EvalContext context,
    RecursionGuard guard,
  ) {
    final stack = <dynamic>[]; // Can hold double, Complex, or Matrix
    final angle = mode == AngleMode.rad ? 1.0 : math.pi / 180;

    for (final tok in t) {
      if (_isNumber(tok)) {
        stack.add(double.parse(tok));
      } else if (tok == '__I__') {
        stack.add(const Complex(0, 1));
      } else if (tok == ',') {
        // Separator for function args - handled by function logic
        continue;
      } else if (tok == ';') {
        // Matrix row separator
        continue;
      } else if (tok == 'u-') {
        if (stack.isEmpty) {
          throw const EvalError(EvalErrorType.syntax, 'Unary minus error');
        }
        final v = stack.removeLast();
        if (v is double) {
          stack.add(-v);
        } else if (v is Complex) {
          stack.add(-v);
        } else if (v is Matrix) {
          stack.add(v * -1.0);
        }
      } else if (tok == 'u+') {
        if (stack.isEmpty) {
          throw const EvalError(EvalErrorType.syntax, 'Unary plus error');
        }
      } else if (tok == '!') {
        if (stack.isEmpty) {
          throw const EvalError(EvalErrorType.syntax, 'Factorial error');
        }
        final v = _toDouble(stack.removeLast());
        if (v < 0 || v != v.floor()) {
          throw const EvalError(EvalErrorType.domain, 'Factorial domain');
        }
        if (v > 170) {
          throw const EvalError(EvalErrorType.domain, 'Factorial overflow');
        }
        stack.add(_factorial(v.toInt()).toDouble());
      } else if (_isFunction(tok)) {
        _evalFunction(tok, stack, angle, mode, context, guard);
      } else if (_isIdentifier(tok)) {
        if (context.variables.containsKey(tok)) {
          stack.add(context.variables[tok]!);
        } else if (context.matrices.containsKey(tok)) {
          stack.add(context.matrices[tok]!);
        } else if (context.complexVars.containsKey(tok)) {
          stack.add(context.complexVars[tok]!);
        } else {
          throw EvalError(EvalErrorType.syntax, 'Unknown variable: $tok');
        }
      } else {
        // Binary operators
        _evalBinaryOp(tok, stack);
      }
    }

    if (stack.length != 1) {
      throw const EvalError(EvalErrorType.syntax, 'Invalid expression');
    }

    final result = stack.single;
    return result is double ? result : result;
  }

  void _evalFunction(
    String tok,
    List<dynamic> stack,
    double angle,
    AngleMode mode,
    EvalContext context,
    RecursionGuard guard,
  ) {
    // Standard functions
    switch (tok) {
      case 'sin':
      case 'cos':
      case 'tan':
      case 'sinh':
      case 'cosh':
      case 'tanh':
        final v = _toDouble(stack.removeLast());
        final a =
            tok.startsWith('sin') ||
                tok.startsWith('cos') ||
                tok.startsWith('tan')
            ? v * angle
            : v;
        if (tok == 'sin')
          stack.add(math.sin(a));
        else if (tok == 'cos')
          stack.add(math.cos(a));
        else if (tok == 'tan')
          stack.add(math.tan(a));
        else if (tok == 'sinh')
          stack.add((math.exp(a) - math.exp(-a)) / 2);
        else if (tok == 'cosh')
          stack.add((math.exp(a) + math.exp(-a)) / 2);
        else if (tok == 'tanh') {
          final ea = math.exp(a);
          final ena = math.exp(-a);
          stack.add((ea - ena) / (ea + ena));
        }
        break;

      case 'asin':
      case 'acos':
      case 'atan':
        final v = _toDouble(stack.removeLast());
        double result;
        if (tok == 'asin')
          result = math.asin(v);
        else if (tok == 'acos')
          result = math.acos(v);
        else
          result = math.atan(v);
        stack.add(result / angle);
        break;

      case 'asinh':
      case 'acosh':
      case 'atanh':
        final v = _toDouble(stack.removeLast());
        if (tok == 'asinh') {
          stack.add(math.log(v + math.sqrt(v * v + 1)));
        } else if (tok == 'acosh') {
          if (v < 1)
            throw const EvalError(EvalErrorType.domain, 'acosh(x) x<1');
          stack.add(math.log(v + math.sqrt(v * v - 1)));
        } else {
          if (v.abs() >= 1) {
            throw const EvalError(EvalErrorType.domain, 'atanh(x) |x|>=1');
          }
          stack.add(0.5 * math.log((1 + v) / (1 - v)));
        }
        break;

      case 'ln':
      case 'log':
        final v = _toDouble(stack.removeLast());
        if (v <= 0) {
          throw EvalError(EvalErrorType.domain, '$tok(x) x<=0');
        }
        stack.add(tok == 'ln' ? math.log(v) : math.log(v) / math.ln10);
        break;

      case 'sqrt':
        final v = stack.removeLast();
        if (v is double) {
          if (v < 0) {
            stack.add(Complex(0, math.sqrt(-v)));
          } else {
            stack.add(math.sqrt(v));
          }
        } else if (v is Complex) {
          final r = v.magnitude;
          final theta = v.argument;
          stack.add(Complex.fromPolar(math.sqrt(r), theta / 2));
        }
        break;

      case 'cbrt':
        final v = _toDouble(stack.removeLast());
        stack.add(v < 0 ? -math.pow(-v, 1 / 3) : math.pow(v, 1 / 3));
        break;

      case 'abs':
        final v = stack.removeLast();
        if (v is double) {
          stack.add(v.abs());
        } else if (v is Complex) {
          stack.add(v.magnitude);
        }
        break;

      case 'round':
        stack.add(_toDouble(stack.removeLast()).round().toDouble());
        break;

      case 'floor':
        stack.add(_toDouble(stack.removeLast()).floor().toDouble());
        break;

      case 'ceil':
        stack.add(_toDouble(stack.removeLast()).ceil().toDouble());
        break;

      // Matrix functions
      case 'det':
        final m = stack.removeLast();
        if (m is! Matrix) {
          throw const EvalError(EvalErrorType.syntax, 'det requires matrix');
        }
        final d = m.determinant();
        if (d == null) {
          throw const EvalError(EvalErrorType.dimension, 'Not square matrix');
        }
        stack.add(d);
        break;

      case 'transpose':
        final m = stack.removeLast();
        if (m is! Matrix) {
          throw const EvalError(
            EvalErrorType.syntax,
            'transpose requires matrix',
          );
        }
        stack.add(m.transpose());
        break;

      case 'identity':
        final n = _toDouble(stack.removeLast()).toInt();
        stack.add(Matrix.identity(n));
        break;

      // Complex functions
      case 'Re':
        final v = stack.removeLast();
        stack.add(v is Complex ? v.real : _toDouble(v));
        break;

      case 'Im':
        final v = stack.removeLast();
        stack.add(v is Complex ? v.imag : 0.0);
        break;

      case 'conj':
        final v = stack.removeLast();
        if (v is Complex) {
          stack.add(v.conjugate());
        } else {
          stack.add(v);
        }
        break;

      case 'arg':
        final v = stack.removeLast();
        if (v is Complex) {
          stack.add(v.argument);
        } else {
          stack.add(0.0);
        }
        break;

      default:
        throw EvalError(EvalErrorType.syntax, 'Unknown function: $tok');
    }
  }

  void _evalBinaryOp(String tok, List<dynamic> stack) {
    if (stack.length < 2) {
      throw const EvalError(EvalErrorType.syntax, 'Binary operator error');
    }

    final b = stack.removeLast();
    final a = stack.removeLast();

    switch (tok) {
      case '+':
        stack.add(_add(a, b));
        break;
      case '-':
        stack.add(_subtract(a, b));
        break;
      case '*':
        stack.add(_multiply(a, b));
        break;
      case '/':
        stack.add(_divide(a, b));
        break;
      case '^':
        stack.add(_power(a, b));
        break;
      default:
        throw EvalError(EvalErrorType.syntax, 'Unknown operator: $tok');
    }
  }

  // ===================== ARITHMETIC HELPERS =====================

  dynamic _add(dynamic a, dynamic b) {
    if (a is double && b is double) return a + b;
    if (a is Complex || b is Complex) {
      return _toComplex(a) + _toComplex(b);
    }
    if (a is Matrix && b is Matrix) return a + b;
    throw const EvalError(EvalErrorType.syntax, 'Type mismatch in addition');
  }

  dynamic _subtract(dynamic a, dynamic b) {
    if (a is double && b is double) return a - b;
    if (a is Complex || b is Complex) {
      return _toComplex(a) - _toComplex(b);
    }
    if (a is Matrix && b is Matrix) return a - b;
    throw const EvalError(EvalErrorType.syntax, 'Type mismatch in subtraction');
  }

  dynamic _multiply(dynamic a, dynamic b) {
    if (a is double && b is double) return a * b;
    if (a is Complex || b is Complex) {
      return _toComplex(a) * _toComplex(b);
    }
    if (a is Matrix && b is Matrix) return a * b;
    if (a is Matrix && b is double) return a * b;
    if (a is double && b is Matrix) return b * a;
    throw const EvalError(
      EvalErrorType.syntax,
      'Type mismatch in multiplication',
    );
  }

  dynamic _divide(dynamic a, dynamic b) {
    if (a is double && b is double) {
      if (b == 0) {
        throw const EvalError(EvalErrorType.divisionByZero, 'Division by zero');
      }
      return a / b;
    }
    if (a is Complex || b is Complex) {
      return _toComplex(a) / _toComplex(b);
    }
    throw const EvalError(EvalErrorType.syntax, 'Type mismatch in division');
  }

  dynamic _power(dynamic a, dynamic b) {
    if (a is double && b is double) {
      return math.pow(a, b).toDouble();
    }
    if (a is Complex || b is Complex) {
      final ca = _toComplex(a);
      final cb = _toComplex(b);
      // z^w = exp(w * ln(z))
      final r = ca.magnitude;
      final theta = ca.argument;
      final lnZ = Complex(math.log(r), theta);
      final product = cb * lnZ;
      final expReal = math.exp(product.real);
      return Complex.fromPolar(expReal, product.imag);
    }
    throw const EvalError(EvalErrorType.syntax, 'Type mismatch in power');
  }

  // ===================== TYPE CONVERSIONS =====================

  double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is Complex) return v.real; // Take real part
    throw EvalError(
      EvalErrorType.syntax,
      'Cannot convert ${v.runtimeType} to double',
    );
  }

  Complex _toComplex(dynamic v) {
    if (v is Complex) return v;
    if (v is double) return Complex(v, 0);
    throw EvalError(
      EvalErrorType.syntax,
      'Cannot convert ${v.runtimeType} to complex',
    );
  }

  // ===================== UTILITIES =====================

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  bool _isNumber(String s) => double.tryParse(s) != null;

  bool _isFunction(String s) => const {
    'sin',
    'cos',
    'tan',
    'asin',
    'acos',
    'atan',
    'sinh',
    'cosh',
    'tanh',
    'asinh',
    'acosh',
    'atanh',
    'ln',
    'log',
    'sqrt',
    'cbrt',
    'abs',
    'round',
    'floor',
    'ceil',
    'det',
    'transpose',
    'identity',
    'Re',
    'Im',
    'conj',
    'arg',
  }.contains(s);

  bool _isMatrixFunction(String s) =>
      const {'det', 'transpose', 'identity'}.contains(s);

  bool _isIdentifier(String s) =>
      RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(s) && !_isFunction(s);
}
