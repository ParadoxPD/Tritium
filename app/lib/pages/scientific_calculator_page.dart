import 'package:app/core/evaluator/eval_types.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/calculator_state.dart';
import '../widgets/calculator_button.dart';

class ScientificCalculatorPage extends StatelessWidget {
  const ScientificCalculatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorState>();

    return Column(
      children: [
        // DISPLAY
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerRight,
          color: const Color(0xFF1E1E1E),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final dx = details.localPosition.dx;

                  final charWidth = 14.0; // approximate
                  final index = (dx / charWidth).floor();

                  state.setCursor(index);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      for (int i = 0; i <= state.expression.length; i++)
                        TextSpan(
                          text: i == state.cursor
                              ? '|'
                              : (i < state.expression.length
                                    ? state.expression[i]
                                    : ''),
                          style: TextStyle(
                            fontSize: 24,
                            color: i == state.cursor
                                ? Colors.green
                                : Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                state.display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                state.angleMode == AngleMode.rad ? 'RAD' : 'DEG',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
          ),
        ),

        // BUTTONS
        Expanded(
          child: GridView.count(
            crossAxisCount: 5,
            padding: const EdgeInsets.all(4),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: _buttons(context),
          ),
        ),
      ],
    );
  }

  List<Widget> _buttons(BuildContext context) {
    void press(String v) => context.read<CalculatorState>().input(v);

    Widget btn(String t, Color c) =>
        CalculatorButton(text: t, color: c, onPressed: press);

    return [
      btn('sin(', Colors.blue.shade700),
      btn('cos(', Colors.blue.shade700),
      btn('tan(', Colors.blue.shade700),
      btn('ln(', Colors.blue.shade700),
      btn('log(', Colors.blue.shade700),

      btn('sqrt(', Colors.blue.shade700),
      btn('^', Colors.blue.shade700),
      btn('π', Colors.blue.shade700),
      btn('e', Colors.blue.shade700),
      btn('RAD/DEG', Colors.green.shade700),

      btn('7', Colors.grey.shade800),
      btn('8', Colors.grey.shade800),
      btn('9', Colors.grey.shade800),
      btn('C', Colors.red.shade700),
      btn('DEL', Colors.red.shade700),

      btn('4', Colors.grey.shade800),
      btn('5', Colors.grey.shade800),
      btn('6', Colors.grey.shade800),
      btn('*', Colors.orange.shade700),
      btn('/', Colors.orange.shade700),

      btn('1', Colors.grey.shade800),
      btn('2', Colors.grey.shade800),
      btn('3', Colors.grey.shade800),
      btn('+', Colors.orange.shade700),
      btn('-', Colors.orange.shade700),

      btn('0', Colors.grey.shade800),
      btn('.', Colors.grey.shade800),
      btn('=', Colors.green.shade700),
      btn('(', Colors.grey.shade700),
      btn(')', Colors.grey.shade700),

      btn('ANS', Colors.grey.shade700),
      btn('MC', Colors.grey.shade700),
      btn('MR', Colors.grey.shade700),
      btn('M+', Colors.grey.shade700),
      btn('M-', Colors.grey.shade700),
    ];
  }
}
