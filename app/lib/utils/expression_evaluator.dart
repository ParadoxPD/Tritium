import 'dart:math' as math;

class ExpressionEvaluator {
  String evaluate(String expr, bool isRadians) {
    expr = expr.replaceAll('π', math.pi.toString());
    expr = expr.replaceAll('e', math.e.toString());
    expr = _handleScientificFunctions(expr, isRadians);

    try {
      final result = _simpleEval(expr);
      return result
          .toStringAsFixed(10)
          .replaceFirst(RegExp(r'\.0+$'), '')
          .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'\1');
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  String _handleScientificFunctions(String expr, bool isRadians) {
    final double angle = isRadians ? 1 : math.pi / 180;

    expr = expr.replaceAllMapped(RegExp(r'sin\(([\d.]+)\)'), (match) {
      return math.sin(double.parse(match.group(1)!) * angle).toString();
    });
    expr = expr.replaceAllMapped(RegExp(r'cos\(([\d.]+)\)'), (match) {
      return math.cos(double.parse(match.group(1)!) * angle).toString();
    });
    expr = expr.replaceAllMapped(RegExp(r'tan\(([\d.]+)\)'), (match) {
      return math.tan(double.parse(match.group(1)!) * angle).toString();
    });
    expr = expr.replaceAllMapped(RegExp(r'ln\(([\d.]+)\)'), (match) {
      return math.log(double.parse(match.group(1)!)).toString();
    });
    expr = expr.replaceAllMapped(RegExp(r'log\(([\d.]+)\)'), (match) {
      return (math.log(double.parse(match.group(1)!)) / math.ln10).toString();
    });
    expr = expr.replaceAllMapped(RegExp(r'sqrt\(([\d.]+)\)'), (match) {
      return math.sqrt(double.parse(match.group(1)!)).toString();
    });

    return expr;
  }

  double _simpleEval(String expr) {
    final cleaned = expr.replaceAll(' ', '');
    return _evalAddSub(cleaned);
  }

  double _evalAddSub(String expr) {
    final parts = <String>[];
    final ops = <String>[];
    String current = '';

    for (int i = 0; i < expr.length; i++) {
      if (expr[i] == '+' || expr[i] == '-') {
        if (current.isNotEmpty) {
          parts.add(current);
          ops.add(expr[i]);
          current = '';
        }
      } else {
        current += expr[i];
      }
    }
    if (current.isNotEmpty) parts.add(current);

    double result = _evalMulDiv(parts[0]);
    for (int i = 0; i < ops.length; i++) {
      final nextVal = _evalMulDiv(parts[i + 1]);
      if (ops[i] == '+') {
        result += nextVal;
      } else {
        result -= nextVal;
      }
    }
    return result;
  }

  double _evalMulDiv(String expr) {
    final parts = expr.split(RegExp(r'[*/]'));
    final ops = <String>[];
    for (final char in expr.split('')) {
      if (char == '*' || char == '/') ops.add(char);
    }

    double result = _evalPower(parts[0]);
    for (int i = 0; i < ops.length; i++) {
      final nextVal = _evalPower(parts[i + 1]);
      if (ops[i] == '*') {
        result *= nextVal;
      } else {
        result /= nextVal;
      }
    }
    return result;
  }

  double _evalPower(String expr) {
    if (expr.contains('^')) {
      final parts = expr.split('^');
      return math
          .pow(double.parse(parts[0]), double.parse(parts[1]))
          .toDouble();
    }
    return double.parse(expr);
  }
}
