import 'package:flutter/material.dart';
import '../widgets/calculator_button.dart';
import '../utils/expression_evaluator.dart';
import 'dart:math' as math;

class ScientificCalculatorPage extends StatefulWidget {
  const ScientificCalculatorPage({Key? key}) : super(key: key);

  @override
  State<ScientificCalculatorPage> createState() =>
      _ScientificCalculatorPageState();
}

class _ScientificCalculatorPageState extends State<ScientificCalculatorPage> {
  String display = '0';
  String expression = '';
  bool isRadians = true;
  final ExpressionEvaluator _evaluator = ExpressionEvaluator();

  void onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        display = '0';
        expression = '';
      } else if (value == '=') {
        try {
          display = _evaluator.evaluate(expression, isRadians);
          expression = display;
        } catch (e) {
          display = 'Error';
        }
      } else if (value == 'DEL') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
          display = expression.isEmpty ? '0' : expression;
        }
      } else if (value == 'RAD/DEG') {
        isRadians = !isRadians;
      } else {
        if (display == '0' || display == 'Error') {
          expression = value;
        } else {
          expression += value;
        }
        display = expression;
      }
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
                isRadians ? 'RAD' : 'DEG',
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
                text: '/',
                color: Colors.orange.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: 'C',
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
                text: 'DEL',
                color: Colors.red.shade700,
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
                text: '-',
                color: Colors.orange.shade700,
                onPressed: onButtonPressed,
              ),
              CalculatorButton(
                text: '(',
                color: Colors.grey.shade700,
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
                text: '+',
                color: Colors.orange.shade700,
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
}
