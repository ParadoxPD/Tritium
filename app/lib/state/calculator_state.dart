import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool isShift = false;
  bool isAlpha = false;
  bool isHyp = false;

  AngleMode angleMode = AngleMode.rad;

  // Casio 991EX Variables
  final Map<String, double> _memory = {
    'A': 0,
    'B': 0,
    'C': 0,
    'D': 0,
    'E': 0,
    'F': 0,
    'X': 0,
    'Y': 0,
    'Z': 0,
    'M': 0,
    'Ans': 0,
  };

  bool _isStoreMode = false;
  bool _isRecallMode = false;
  int _parenBalance = 0;

  CalculatorState(this.calculator, this.functions) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    angleMode = await AppPrefs.loadAngleMode();
    notifyListeners();
  }

  Map<String, double> get memory => _memory;
  bool get isStoreMode => _isStoreMode;

  void input(String value) {
    // Handle special modes
    if (value == 'STO') {
      _isStoreMode = true;
      display = 'STO?';
      notifyListeners();
      return;
    }

    if (value == 'RCL') {
      _isRecallMode = true;
      display = 'RCL?';
      notifyListeners();
      return;
    }

    // Handle store mode
    if (_isStoreMode) {
      if (_memory.containsKey(value)) {
        double? valToStore = double.tryParse(display);
        if (valToStore != null) {
          _memory[value] = valToStore;
          display = '$valToStore → $value';
          expression = '';
          cursor = 0;
        }
      }
      _isStoreMode = false;
      notifyListeners();
      return;
    }

    // Handle recall mode
    if (_isRecallMode) {
      if (_memory.containsKey(value)) {
        _insert(value);
      }
      _isRecallMode = false;
      notifyListeners();
      return;
    }

    // Standard operations
    if (value == 'AC' || value == 'C') {
      _reset();
      return;
    }

    if (value == '=') {
      _evaluate();
      return;
    }

    if (value == 'DEL') {
      _delete();
      return;
    }

    if (value == '←') {
      if (cursor > 0) cursor--;
      notifyListeners();
      return;
    }

    if (value == '→' || value == 'INS') {
      if (cursor < expression.length) cursor++;
      notifyListeners();
      return;
    }

    // Map button labels to parseable syntax
    String textToInsert = _mapButtonToSyntax(value);

    if (!_canAppend(textToInsert)) return;
    _insert(textToInsert);
  }

  void toggleShift() {
    isShift = !isShift;
    if (isShift) {
      isAlpha = false;
      isHyp = false;
    }
    notifyListeners();
  }

  void toggleAlpha() {
    isAlpha = !isAlpha;
    if (isAlpha) {
      isShift = false;
      isHyp = false;
    }
    notifyListeners();
  }

  void toggleHyp() {
    isHyp = !isHyp;
    notifyListeners();
  }

  void clearShift() {
    isShift = false;
    notifyListeners();
  }

  void clearAlpha() {
    isAlpha = false;
    notifyListeners();
  }

  void clearHyp() {
    isHyp = false;
    notifyListeners();
  }

  void clearModes() {
    isShift = false;
    isAlpha = false;
    isHyp = false;
    notifyListeners();
  }

  void toggleAngleMode() {
    angleMode = angleMode == AngleMode.rad ? AngleMode.deg : AngleMode.rad;
    notifyListeners();
  }

  void setAngleMode(AngleMode mode) {
    angleMode = mode;
    AppPrefs.saveAngleMode(mode);
    notifyListeners();
  }

  void handleButtonPress({
    required String primary,
    String? shift,
    String? alpha,
  }) {
    String toInput = primary;

    if (isHyp) {
      if (primary == 'sin') {
        toInput = 'sinh';
      } else if (primary == 'cos') {
        toInput = 'cosh';
      } else if (primary == 'tan') {
        toInput = 'tanh';
      } else if (shift == 'sin⁻¹') {
        toInput = 'asinh';
      } else if (shift == 'cos⁻¹') {
        toInput = 'acosh';
      } else if (shift == 'tan⁻¹') {
        toInput = 'atanh';
      }
    }

    if (isShift && shift != null) {
      input(shift);
      clearShift();
    } else if (isAlpha && alpha != null) {
      input(alpha);
      clearAlpha();
    } else {
      input(toInput);
    }

    if (isHyp && isTrig(toInput)) {
      clearHyp();
    }
  }

  bool isTrig(String toInput) {
    return (toInput.contains('sin') ||
        toInput.contains('cos') ||
        toInput.contains('tan'));
  }

  String _mapButtonToSyntax(String value) {
    final map = {
      'x⁻¹': '^(-1)',
      'x!': '!',
      '×': '*',
      '÷': '/',
      '^': '^',
      '³√': 'cbrt(',
      '∛': 'cbrt(',
      'log': 'log(',
      '10ˣ': '10^',
      'ln': 'ln(',
      'eˣ': 'e^',
      'sin': 'sin(',
      'cos': 'cos(',
      'tan': 'tan(',
      'sin⁻¹': 'asin(',
      'cos⁻¹': 'acos(',
      'tan⁻¹': 'atan(',
      'sinh': 'sinh(',
      'cosh': 'cosh(',
      'tanh': 'tanh(',
      'asinh': 'asinh(',
      'acosh': 'acosh(',
      'atanh': 'atanh(',
      'nCr': 'C(',
      'nPr': 'P(',
      'Pol(': 'pol(',
      'Rec(': 'rec(',
      '(-)': '(-',
      'Ans': 'Ans',
      '°\'"': '°',
      'π': 'pi',
      'e': 'e',
      'Ran#': math.Random().nextDouble().toStringAsFixed(6),
      'Rnd': 'round(',
      'Abs': 'abs(',
      '×10ˣ': 'E',
      '∫dx': 'int(',
      'd/dx': 'deriv(',
      'Σ(': 'sum(',
      '%': '%',
      'M+': 'M+',
      'M-': 'M-',
      'ENG': 'ENG',
      'CONST': 'CONST',
      'CONV': 'CONV',
    };

    return map[value] ?? value;
  }

  void _reset() {
    display = '0';
    expression = '';
    _parenBalance = 0;
    cursor = 0;
    _isStoreMode = false;
    _isRecallMode = false;
    notifyListeners();
  }

  void _delete() {
    if (cursor == 0 || expression.isEmpty) return;

    // Handle multi-character deletions for functions
    int deleteCount = 1;
    if (cursor >= 4) {
      final sub4 = expression.substring(cursor - 4, cursor);
      if ([
        'sin(',
        'cos(',
        'tan(',
        'log(',
        'pol(',
        'rec(',
        'int(',
      ].contains(sub4)) {
        deleteCount = 4;
      }
    }
    if (cursor >= 5 && deleteCount == 1) {
      final sub5 = expression.substring(cursor - 5, cursor);
      if ([
        'asin(',
        'acos(',
        'atan(',
        'sinh(',
        'cosh(',
        'tanh(',
        'sqrt(',
        'cbrt(',
      ].contains(sub5)) {
        deleteCount = 5;
      }
    }
    if (cursor >= 6 && deleteCount == 1) {
      final sub6 = expression.substring(cursor - 6, cursor);
      if (['asinh(', 'acosh(', 'atanh(', 'deriv(', 'round('].contains(sub6)) {
        deleteCount = 6;
      }
    }

    final removed = expression.substring(cursor - deleteCount, cursor);
    expression = expression.replaceRange(cursor - deleteCount, cursor, '');
    cursor -= deleteCount;

    final openCount = '('.allMatches(removed).length;
    final closeCount = ')'.allMatches(removed).length;
    _parenBalance -= openCount;
    _parenBalance += closeCount;

    display = expression.isEmpty ? '0' : expression;
    notifyListeners();
  }

  void _insert(String value) {
    expression = expression.replaceRange(cursor, cursor, value);
    cursor += value.length;
    display = expression;

    final openCount = '('.allMatches(value).length;
    final closeCount = ')'.allMatches(value).length;
    _parenBalance += openCount;
    _parenBalance -= closeCount;

    notifyListeners();
  }

  void _evaluate() {
    String evalExpr = expression;

    // Auto-close parentheses
    if (_parenBalance > 0) {
      evalExpr += ')' * _parenBalance;
    }

    // Handle memory operations
    if (evalExpr.contains('M+')) {
      final val = double.tryParse(display);
      if (val != null) {
        _memory['M'] = (_memory['M'] ?? 0) + val;
        display = 'M = ${_memory['M']}';
        expression = '';
        cursor = 0;
        notifyListeners();
        return;
      }
    }

    if (evalExpr.contains('M-')) {
      final val = double.tryParse(display);
      if (val != null) {
        _memory['M'] = (_memory['M'] ?? 0) - val;
        display = 'M = ${_memory['M']}';
        expression = '';
        cursor = 0;
        notifyListeners();
        return;
      }
    }

    final result = calculator.evaluate(
      evalExpr,
      angleMode,
      EvalContext(functions: functions.functions, variables: _memory),
    );

    if (result is EvalSuccess) {
      double val = result.value;
      _memory['Ans'] = val;

      final formatted = _formatNumber(val);
      display = formatted;
      expression = formatted;
      cursor = expression.length;
      _parenBalance = 0;
    } else {
      display = 'Math ERROR';
    }
    notifyListeners();
  }

  String _formatNumber(double val) {
    if (val.isNaN) return 'Math ERROR';
    if (val.isInfinite) return val > 0 ? '∞' : '-∞';

    // Use scientific notation for very large or very small numbers
    if (val.abs() >= 1e10 || (val.abs() < 1e-3 && val != 0)) {
      return val.toStringAsExponential(9).replaceFirst(RegExp(r'0+e'), 'e');
    }

    // Regular formatting
    String str = val.toStringAsFixed(10);
    str = str.replaceFirst(RegExp(r'\.?0+$'), '');

    return str;
  }

  bool _canAppend(String value) {
    if (expression.isEmpty && value.isEmpty) return false;

    // Basic validation - you can expand this
    return true;
  }

  void setCursor(int index) {
    cursor = index.clamp(0, expression.length);
    notifyListeners();
  }
}

class AppPrefs {
  static const _angleMode = 'angle_mode';

  static Future<void> saveAngleMode(AngleMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_angleMode, mode.name);
  }

  static Future<AngleMode> loadAngleMode() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_angleMode);
    return AngleMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => AngleMode.rad,
    );
  }
}
