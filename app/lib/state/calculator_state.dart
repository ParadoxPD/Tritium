import 'package:flutter/material.dart';

import '../services/calculator_service.dart';
import '../services/function_service.dart';
import '../core/evaluator/eval_context.dart';
import '../core/evaluator/eval_types.dart';

class CalculatorState extends ChangeNotifier {
  final CalculatorService calculator;
  final FunctionService functions;

  String display = '0';
  String expression = '';
  int cursor = 0;
  AngleMode angleMode = AngleMode.rad;

  int _parenBalance = 0;

  CalculatorState(this.calculator, this.functions);

  // ===============================
  // PUBLIC ENTRY POINT (ONLY ONE)
  // ===============================
  void input(String value) {
    // CLEAR
    if (value == 'C') {
      _reset();
      return;
    }

    // TOGGLE ANGLE
    if (value == 'RAD/DEG') {
      angleMode = angleMode == AngleMode.rad ? AngleMode.deg : AngleMode.rad;
      notifyListeners();
      return;
    }

    // EVALUATE
    if (value == '=') {
      _evaluate();
      return;
    }

    // DELETE
    if (value == 'DEL') {
      _delete();
      return;
    }

    // MEMORY OPS
    if (value == 'MC') {
      calculator.memoryClear();
      return;
    }
    if (value == 'MR') {
      _insert(calculator.memoryRecall().toString());
      return;
    }
    if (value == 'M+') {
      calculator.memoryAdd();
      return;
    }
    if (value == 'M-') {
      calculator.memorySubtract();
      return;
    }

    // APPEND (GRAMMAR-GUARDED)
    if (!_canAppend(value)) return;
    _insert(value);
  }

  // ===============================
  // INTERNAL HELPERS
  // ===============================

  void _reset() {
    display = '0';
    expression = '';
    _parenBalance = 0;
    cursor = 0;
    notifyListeners();
  }

  void _delete() {
    if (cursor == 0 || expression.isEmpty) return;

    final removed = expression[cursor - 1];

    expression = expression.replaceRange(cursor - 1, cursor, '');

    cursor--;

    if (removed == '(') _parenBalance--;
    if (removed == ')') _parenBalance++;

    display = expression.isEmpty ? '0' : expression;
    notifyListeners();
  }

  void _insert(String value) {
    expression = expression.replaceRange(cursor, cursor, value);

    cursor += value.length;
    display = expression;

    if (value == '(') _parenBalance++;
    if (value == ')') _parenBalance--;

    notifyListeners();
  }

  void _evaluate() {
    if (_parenBalance != 0) {
      display = 'Error';
      expression = '';
      _parenBalance = 0;
      notifyListeners();
      return;
    }

    final result = calculator.evaluate(
      expression,
      angleMode,
      EvalContext(functions: functions.functions),
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
    notifyListeners();
  }

  // ===============================
  // GRAMMAR ENFORCEMENT
  // ===============================

  bool _canAppend(String value) {
    if (expression.isEmpty) {
      return !'*/^)'.contains(value);
    }

    final left = cursor == 0 ? '' : expression[cursor - 1];
    final right = cursor == expression.length ? '' : expression[cursor];

    // Operators
    if ('+-*/^'.contains(value)) {
      if (left.isEmpty || '+-*/^('.contains(left)) {
        return value == '-'; // unary minus only
      }
    }

    // Decimal
    if (value == '.') {
      final parts = expression.split(RegExp(r'[+\-*/^()]'));
      return !parts.last.contains('.');
    }

    // Right parenthesis
    if (value == ')') {
      if (_parenBalance == 0) return false;
      if (right.isEmpty || '+-*/^('.contains(right)) return false;
    }

    return true;
  }

  void moveCursorLeft() {
    if (cursor > 0) {
      cursor--;
      notifyListeners();
    }
  }

  void moveCursorRight() {
    if (cursor < expression.length) {
      cursor++;
      notifyListeners();
    }
  }

  void setCursor(int index) {
    cursor = index.clamp(0, expression.length);
    notifyListeners();
  }
}
