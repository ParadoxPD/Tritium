import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/custom_function.dart';

class FunctionTestDialog extends StatefulWidget {
  final CustomFunction function;

  const FunctionTestDialog({Key? key, required this.function})
    : super(key: key);

  @override
  State<FunctionTestDialog> createState() => _FunctionTestDialogState();
}

class _FunctionTestDialogState extends State<FunctionTestDialog> {
  final Map<String, TextEditingController> _controllers = {};
  String _result = '';

  @override
  void initState() {
    super.initState();
    for (var param in widget.function.parameters) {
      _controllers[param] = TextEditingController();
    }
  }

  void _calculate() {
    try {
      String formula = widget.function.formula;

      for (var param in widget.function.parameters) {
        final value = _controllers[param]!.text;
        if (value.isEmpty) {
          throw Exception('All parameters must have values');
        }
        formula = formula.replaceAll(param, value);
      }

      formula = formula.replaceAll('^', 'pow');
      final result = _evaluateFormula(formula);

      setState(() {
        _result = result.toStringAsFixed(6);
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  double _evaluateFormula(String formula) {
    formula = formula.replaceAll(' ', '');
    return _evalExpression(formula);
  }

  double _evalExpression(String expr) {
    while (expr.contains('(')) {
      final start = expr.lastIndexOf('(');
      final end = expr.indexOf(')', start);
      final subExpr = expr.substring(start + 1, end);
      final result = _evalExpression(subExpr);
      expr =
          expr.substring(0, start) +
          result.toString() +
          expr.substring(end + 1);
    }

    return _evalAddSub(expr);
  }

  double _evalAddSub(String expr) {
    final regex = RegExp(r'([+\-])');
    final matches = regex.allMatches(expr);

    if (matches.isEmpty) return _evalMulDiv(expr);

    final parts = expr.split(regex);
    final ops = matches.map((m) => m.group(0)!).toList();

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
    final regex = RegExp(r'([*/])');
    final matches = regex.allMatches(expr);

    if (matches.isEmpty) return _evalPow(expr);

    final parts = expr.split(regex);
    final ops = matches.map((m) => m.group(0)!).toList();

    double result = _evalPow(parts[0]);
    for (int i = 0; i < ops.length; i++) {
      final nextVal = _evalPow(parts[i + 1]);
      if (ops[i] == '*') {
        result *= nextVal;
      } else {
        result /= nextVal;
      }
    }
    return result;
  }

  double _evalPow(String expr) {
    if (expr.startsWith('pow(') && expr.endsWith(')')) {
      final args = expr.substring(4, expr.length - 1).split(',');
      return math.pow(double.parse(args[0]), double.parse(args[1])).toDouble();
    }
    return double.parse(expr);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Test ${widget.function.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.function.parameters
                .map(
                  (param) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _controllers[param],
                      decoration: InputDecoration(
                        labelText: param,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Result: $_result',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
