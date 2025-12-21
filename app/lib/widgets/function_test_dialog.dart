import 'package:flutter/material.dart';
import '../models/custom_function.dart';
import '../utils/expression_evaluator.dart';

class FunctionTestDialog extends StatefulWidget {
  final CustomFunction function;
  final Map<String, FunctionDef> functions;
  const FunctionTestDialog({
    Key? key,
    required this.function,
    required this.functions,
  }) : super(key: key);

  @override
  State<FunctionTestDialog> createState() => _FunctionTestDialogState();
}

class _FunctionTestDialogState extends State<FunctionTestDialog> {
  final Map<String, TextEditingController> _controllers = {};
  String _result = '';
  final ExpressionEvaluator _evaluator = ExpressionEvaluator();

  @override
  void initState() {
    super.initState();
    for (final p in widget.function.parameters) {
      _controllers[p] = TextEditingController();
    }
  }

  void _calculate() {
    try {
      String expr = widget.function.formula;

      for (final param in widget.function.parameters) {
        final value = _controllers[param]!.text.trim();
        if (value.isEmpty) {
          throw const EvalError(
            EvalErrorType.syntax,
            'All parameters must have values',
          );
        }

        // Replace only whole identifiers
        expr = expr.replaceAllMapped(
          RegExp(r'\b' + RegExp.escape(param) + r'\b'),
          (_) => value,
        );
      }

      final result = _evaluator.evaluate(
        expr,
        AngleMode.rad,
        context: EvalContext(functions: widget.functions),
      );

      setState(() {
        if (result is EvalSuccess) {
          _result = result.value
              .toStringAsFixed(6)
              .replaceFirst(RegExp(r'\.0+$'), '')
              .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'\1');
        } else if (result is EvalError) {
          _result = 'Error: ${result.message}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Test ${widget.function.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...widget.function.parameters.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[p],
                  decoration: InputDecoration(
                    labelText: p,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
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
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
