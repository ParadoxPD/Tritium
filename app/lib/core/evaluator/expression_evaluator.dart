import 'dart:math' as math;

import 'package:app/core/evaluator/eval_context.dart';
import 'package:app/core/evaluator/eval_types.dart';

class ExpressionEvaluator {
  final Map<String, double> _cache = {};

  EvaluationResult evaluate(
    String expr,
    AngleMode mode, {
    EvalContext context = const EvalContext(),
    RecursionGuard guard = const RecursionGuard(0, 32),
  }) {
    try {
      final funcSig = context.functions.entries
          .map((e) => '${e.key}(${e.value.params.join(",")}):${e.value.body}')
          .join('|');

      final key = '$expr|$mode|${context.variables}|$funcSig';

      if (_cache.containsKey(key)) {
        return EvalSuccess(_cache[key]!);
      }

      final tokens = _insertImplicitMultiplication(_tokenize(expr));
      final postfix = _toPostfix(tokens);
      final result = _evalPostfix(postfix, mode, context, guard);
      _cache[key] = result;
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

        if (c == ',') {
          tokens.add(',');
          continue;
        }

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

    bool isValue(String x) => _isNumber(x) || x == ')';
    bool isStart(String x) => _isNumber(x) || x == '(' || _isFunction(x);

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
      } else if (tok == ',') {
        while (stack.isNotEmpty && stack.last != '(') {
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

  double _evalPostfix(
    List<String> t,
    AngleMode mode,
    EvalContext context,
    RecursionGuard guard,
  ) {
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
      } else if (context.functions.containsKey(tok)) {
        final def = context.functions[tok]!;

        if (stack.length < def.params.length) {
          throw EvalError(
            EvalErrorType.syntax,
            'Function $tok expects ${def.params.length} arguments',
          );
        }

        // Pop arguments (reverse order)
        final args = <double>[];
        for (int i = 0; i < def.params.length; i++) {
          args.insert(0, stack.removeLast());
        }

        // New variable scope
        final newVars = Map<String, double>.from(context.variables);
        for (int i = 0; i < def.params.length; i++) {
          newVars[def.params[i]] = args[i];
        }

        final result = evaluate(
          def.body,
          mode,
          context: EvalContext(
            variables: newVars,
            functions: context.functions,
          ),
          guard: guard.next(),
        );

        if (result is EvalSuccess) {
          stack.add(result.value);
        } else {
          throw result as EvalError;
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
          case 'abs':
            stack.add(v.abs());
            break;

          case 'fact':
            if (v < 0 || v != v.floor()) {
              throw const EvalError(
                EvalErrorType.domain,
                'factorial domain error',
              );
            }
            if (v > 20) {
              throw const EvalError(
                EvalErrorType.domain,
                'factorial too large',
              );
            }
            int res = 1;
            for (int i = 1; i <= v; i++) {
              res *= i;
            }
            stack.add(res.toDouble());
            break;
        }
      } else if (_isIdentifier(tok)) {
        if (!context.variables.containsKey(tok)) {
          throw EvalError(EvalErrorType.syntax, 'Unknown variable: $tok');
        }
        stack.add(context.variables[tok]!);
      } else if (tok == 'mod') {
        if (stack.length < 2) {
          throw const EvalError(EvalErrorType.syntax, 'mod(a,b) needs 2 args');
        }
        final b = stack.removeLast();
        final a = stack.removeLast();
        if (b == 0) {
          throw const EvalError(EvalErrorType.divisionByZero, 'mod by zero');
        }
        stack.add(a - b * (a / b).floor());
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
  bool _isFunction(String s) => const {
    'sin',
    'cos',
    'tan',
    'ln',
    'log',
    'sqrt',
    'abs',
    'mod',
    'fact',
  }.contains(s);
  bool _isIdentifier(String s) =>
      RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(s) && !_isFunction(s);
}
