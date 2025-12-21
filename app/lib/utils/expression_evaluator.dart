import 'dart:math' as math;

enum AngleMode { rad, deg }

sealed class EvaluationResult {
  const EvaluationResult();
}

class EvalSuccess extends EvaluationResult {
  final double value;
  const EvalSuccess(this.value);
}

class EvalError extends EvaluationResult {
  final EvalErrorType type;
  final String message;
  const EvalError(this.type, this.message);
}

enum EvalErrorType { syntax, divisionByZero, domain, unknown }

class ExpressionEvaluator {
  EvaluationResult evaluate(String expr, AngleMode mode) {
    try {
      final tokens = _insertImplicitMultiplication(_tokenize(expr));
      final postfix = _toPostfix(tokens);
      final result = _evalPostfix(postfix, mode);
      return EvalSuccess(result);
    } on EvalError catch (e) {
      return e;
    } catch (e) {
      return const EvalError(EvalErrorType.unknown, 'Unknown error');
    }
  }

  /* ===================== TOKENIZER ===================== */

  List<String> _tokenize(String expr) {
    expr = expr
        .replaceAll('π', math.pi.toString())
        .replaceAllMapped(
          RegExp(r'(?<![\w.])e(?![\w.])'),
          (_) => math.e.toString(),
        );

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

        if ('+-*/^()'.contains(c)) {
          if ((c == '-' || c == '+') &&
              (tokens.isEmpty || '()+-*/^'.contains(tokens.last))) {
            tokens.add(c == '-' ? 'u-' : 'u+');
          } else {
            tokens.add(c);
          }
        } else {
          buf.write(c);
          while (i + 1 < expr.length &&
              RegExp(r'[a-z]').hasMatch(expr[i + 1])) {
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

  /* ===================== IMPLICIT MULTIPLICATION ===================== */

  List<String> _insertImplicitMultiplication(List<String> t) {
    final out = <String>[];
    for (int i = 0; i < t.length; i++) {
      out.add(t[i]);
      if (i == t.length - 1) break;

      final a = t[i];
      final b = t[i + 1];

      final left = _isNumber(a) || a == ')' || _isFunction(a);
      final right = _isNumber(b) || b == '(' || _isFunction(b);

      if (left && right) {
        out.add('*');
      }
    }
    return out;
  }

  /* ===================== SHUNTING YARD ===================== */

  List<String> _toPostfix(List<String> tokens) {
    final out = <String>[];
    final stack = <String>[];

    final prec = {'u+': 5, 'u-': 5, '^': 4, '*': 3, '/': 3, '+': 2, '-': 2};

    final rightAssoc = {'^', 'u-', 'u+'};

    for (final tok in tokens) {
      if (_isNumber(tok)) {
        out.add(tok);
      } else if (_isFunction(tok)) {
        stack.add(tok);
      } else if (tok == '(') {
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
      if (stack.last == '(') {
        throw const EvalError(EvalErrorType.syntax, 'Mismatched parentheses');
      }
      out.add(stack.removeLast());
    }
    return out;
  }

  /* ===================== POSTFIX ===================== */

  double _evalPostfix(List<String> t, AngleMode mode) {
    final stack = <double>[];
    final angle = mode == AngleMode.rad ? 1.0 : math.pi / 180;

    for (final tok in t) {
      if (_isNumber(tok)) {
        stack.add(double.parse(tok));
      } else if (tok == 'u-') {
        if (stack.isEmpty) {
          throw const EvalError(EvalErrorType.syntax, 'Unary minus error');
        }
        stack.add(-stack.removeLast());
      } else if (tok == 'u+') {
        if (stack.isEmpty) {
          throw const EvalError(EvalErrorType.syntax, 'Unary plus error');
        }
      } else if (_isFunction(tok)) {
        if (stack.isEmpty) {
          throw const EvalError(
            EvalErrorType.syntax,
            'Missing function argument',
          );
        }
        final v = stack.removeLast();
        switch (tok) {
          case 'sin':
            stack.add(math.sin(v * angle));
            break;
          case 'cos':
            stack.add(math.cos(v * angle));
            break;
          case 'tan':
            stack.add(math.tan(v * angle));
            break;
          case 'ln':
            if (v <= 0) {
              throw const EvalError(EvalErrorType.domain, 'ln(x) x<=0');
            }
            stack.add(math.log(v));
            break;
          case 'log':
            if (v <= 0) {
              throw const EvalError(EvalErrorType.domain, 'log(x) x<=0');
            }
            stack.add(math.log(v) / math.ln10);
            break;
          case 'sqrt':
            if (v < 0) {
              throw const EvalError(EvalErrorType.domain, 'sqrt(x) x<0');
            }
            stack.add(math.sqrt(v));
            break;
        }
      } else {
        if (stack.length < 2) {
          throw const EvalError(EvalErrorType.syntax, 'Binary operator error');
        }
        final b = stack.removeLast();
        final a = stack.removeLast();
        switch (tok) {
          case '+':
            stack.add(a + b);
            break;
          case '-':
            stack.add(a - b);
            break;
          case '*':
            stack.add(a * b);
            break;
          case '/':
            if (b == 0) {
              throw const EvalError(
                EvalErrorType.divisionByZero,
                'Division by zero',
              );
            }
            stack.add(a / b);
            break;
          case '^':
            stack.add(math.pow(a, b).toDouble());
            break;
        }
      }
    }

    if (stack.length != 1) {
      throw const EvalError(EvalErrorType.syntax, 'Invalid expression');
    }
    return stack.single;
  }

  bool _isNumber(String s) => double.tryParse(s) != null;
  bool _isFunction(String s) =>
      const {'sin', 'cos', 'tan', 'ln', 'log', 'sqrt'}.contains(s);
}
