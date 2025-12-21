import 'package:flutter/material.dart';
import '../widgets/calculator_button.dart';
import '../utils/expression_evaluator.dart';

enum TokenType {
  number,
  decimal,
  operator,
  function,
  leftParen,
  rightParen,
  constant,
}

class ScientificCalculatorPage extends StatefulWidget {
  final Map<String, FunctionDef> functions;

  const ScientificCalculatorPage({Key? key, required this.functions})
    : super(key: key);

  @override
  State<ScientificCalculatorPage> createState() =>
      _ScientificCalculatorPageState();
}

class _ScientificCalculatorPageState extends State<ScientificCalculatorPage> {
  String display = '0';
  String expression = '';
  int _parenBalance = 0;

  AngleMode angleMode = AngleMode.rad;
  final ExpressionEvaluator _evaluator = ExpressionEvaluator();
  void onButtonPressed(String value) {
    setState(() {
      // CLEAR
      if (value == 'C') {
        display = '0';
        expression = '';
        _parenBalance = 0;
        return;
      }

      // EVALUATE
      if (value == '=') {
        if (_parenBalance != 0) {
          display = 'Error';
          expression = '';
          _parenBalance = 0;
          return;
        }

        final result = _evaluator.evaluate(
          expression,
          angleMode,
          context: EvalContext(functions: widget.functions),
        );

        if (result is EvalSuccess) {
          final formatted = result.value
              .toStringAsFixed(10)
              .replaceFirst(RegExp(r'\.0+$'), '')
              .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'\1');

          display = formatted;
          expression = formatted;
        } else {
          display = 'Error';
          expression = '';
          _parenBalance = 0;
        }
        return;
      }

      // DELETE
      if (value == 'DEL') {
        if (expression.isNotEmpty) {
          final removed = expression.characters.last;
          expression = expression.substring(0, expression.length - 1);

          if (removed == '(') _parenBalance--;
          if (removed == ')') _parenBalance++;

          display = expression.isEmpty ? '0' : expression;
        }
        return;
      }

      // RAD / DEG
      if (value == 'RAD/DEG') {
        angleMode = angleMode == AngleMode.rad ? AngleMode.deg : AngleMode.rad;
        return;
      }

      // GRAMMAR CHECK
      if (!_canAppend(value)) return;

      // APPEND
      if (display == '0' || display == 'Error') {
        expression = value;
      } else {
        expression += value;
      }

      if (value == '(') _parenBalance++;
      if (value == ')') _parenBalance--;

      display = expression;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerRight,
          color: const Color(0xFF1E1E1E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                expression,
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                angleMode == AngleMode.rad ? 'RAD' : 'DEG',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
          ),
        ),
        // Buttons
        Expanded(
          child: GridView.count(
            crossAxisCount: 5,
            padding: const EdgeInsets.all(4),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              CalculatorButton(
                text: 'sin(',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'cos(',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'tan(',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'ln(',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'log(',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),

              CalculatorButton(
                text: 'sqrt(',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '^',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'π',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'e',
                color: Colors.blue.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'RAD/DEG',
                color: Colors.green.shade700,
                onPressed: onButtonPressed,
              ),

              CalculatorButton(
                text: '7',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '8',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '9',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'C',
                color: Colors.red.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'DEL',
                color: Colors.red.shade700,
                onPressed: onButtonPressed,
              ),

              CalculatorButton(
                text: '4',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '5',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '6',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '*',
                color: Colors.orange.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '/',
                color: Colors.orange.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '1',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '2',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '3',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '+',
                color: Colors.orange.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '-',
                color: Colors.orange.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '0',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '.',
                color: Colors.grey.shade800,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '=',
                color: Colors.green.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '(',
                color: Colors.grey.shade700,
                onPressed: onButtonPressed,
              ),

              CalculatorButton(
                text: ')',
                color: Colors.grey.shade700,
                onPressed: onButtonPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  TokenType _tokenType(String v) {
    if ('0123456789'.contains(v)) return TokenType.number;
    if (v == '.') return TokenType.decimal;
    if ('+-*/^'.contains(v)) return TokenType.operator;
    if (v == '(') return TokenType.leftParen;
    if (v == ')') return TokenType.rightParen;
    if (v == 'π' || v == 'e') return TokenType.constant;
    return TokenType.function; // sin, cos, log, etc.
  }

  bool _canAppend(String value) {
    if (expression.isEmpty) {
      // Expression start rules
      return !'*/^)'.contains(value);
    }

    final last = expression.characters.last;
    final lastType = _tokenType(last);
    final currType = _tokenType(value);

    // Operator rules
    if (currType == TokenType.operator) {
      if (lastType == TokenType.operator || lastType == TokenType.leftParen) {
        // Allow unary minus
        return value == '-';
      }
    }

    // Decimal rules
    if (currType == TokenType.decimal) {
      // Prevent multiple decimals in same number
      final parts = expression.split(RegExp(r'[+\-*/^()]'));

      return !parts.last.contains('.');
    }

    // Right parenthesis rules
    if (currType == TokenType.rightParen) {
      if (_parenBalance == 0) return false;
      if (lastType == TokenType.operator || lastType == TokenType.leftParen) {
        return false;
      }
    }

    // Left parenthesis rules
    if (currType == TokenType.leftParen) {
      if (lastType == TokenType.number ||
          lastType == TokenType.constant ||
          lastType == TokenType.rightParen) {
        // implicit multiplication allowed
        return true;
      }
    }

    return true;
  }
}
