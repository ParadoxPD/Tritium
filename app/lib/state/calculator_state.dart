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

  // Use TextEditingController for native cursor and scrolling support
  final TextEditingController controller = TextEditingController();
  final ScrollController textScrollController = ScrollController();

  String display = '0'; // The result display (bottom line)
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
    // Listen to controller changes if needed,
    // though we mostly update display on specific actions.
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    angleMode = await AppPrefs.loadAngleMode();
    notifyListeners();
  }

  Map<String, double> get memory => _memory;
  bool get isStoreMode => _isStoreMode;

  // --- Input Handling ---

  void input(String value) {
    print(value);
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
          controller.clear();
        }
      }
      _isStoreMode = false;
      notifyListeners();
      return;
    }

    // Handle recall mode
    if (_isRecallMode) {
      if (_memory.containsKey(value)) {
        _insertAtCursor(value);
      }
      _isRecallMode = false;
      notifyListeners();
      return;
    }

    // Standard operations
    if (value == 'AC') {
      _reset();
      return;
    }

    // RESET (Shift + AC)
    if (value == 'RESET') {
      _reset();
      _memory.updateAll((key, value) => 0.0); // Clear memory too
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

    // Cursor movement (handled by TextField mainly, but keeping programmatic hooks)
    if (value == '←') {
      _moveCursor(-1);
      return;
    }
    if (value == '→') {
      _moveCursor(1);
      return;
    }

    // Map button labels to parseable syntax
    String textToInsert = _mapButtonToSyntax(value);
    _insertAtCursor(textToInsert);
    _updateText(textToInsert);
  }

  // --- Logic Helpers ---

  void _insertAtCursor(String text) {
    final textSelection = controller.selection;
    final String currentText = controller.text;

    String newText;
    int newCursorPos;

    if (textSelection.start >= 0) {
      // We have a selection or a valid cursor position
      final newStart = textSelection.start;
      final newEnd = textSelection.end;

      newText = currentText.replaceRange(newStart, newEnd, text);
      newCursorPos = newStart + text.length;
    } else {
      // Append to end if no cursor
      newText = currentText + text;
      newCursorPos = newText.length;
    }

    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: newCursorPos);

    // Track parentheses for auto-close logic
    final openCount = '('.allMatches(text).length;
    final closeCount = ')'.allMatches(text).length;
    _parenBalance += (openCount - closeCount);

    notifyListeners();
  }

  void _delete() {
    final text = controller.text;
    final selection = controller.selection;

    if (text.isEmpty) return;

    // Case 1: Range selected -> delete range
    if (!selection.isCollapsed) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: selection.start);
      _recalculateParens(newText);
      notifyListeners();
      return;
    }

    // Case 2: Cursor at start -> do nothing
    if (selection.baseOffset <= 0) return;

    // Case 3: Intelligent deletion (detect functions like "sin(")
    int cursor = selection.baseOffset;
    int deleteCount = 1;

    // Check backwards from cursor for known functions
    if (cursor >= 4) {
      final sub4 = text.substring(cursor - 4, cursor);
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
      final sub5 = text.substring(cursor - 5, cursor);
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
    // ... add other lengths if necessary

    final newText = text.replaceRange(cursor - deleteCount, cursor, '');
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: cursor - deleteCount,
    );

    _recalculateParens(newText);
    notifyListeners();
  }

  void _reset() {
    controller.clear();
    display = '0';
    _parenBalance = 0;
    _isStoreMode = false;
    _isRecallMode = false;
    notifyListeners();
  }

  void _moveCursor(int delta) {
    final text = controller.text;
    final selection = controller.selection;
    if (text.isEmpty) return;

    int newOffset = (selection.baseOffset + delta).clamp(0, text.length);
    controller.selection = TextSelection.collapsed(offset: newOffset);
    notifyListeners();
  }

  void _recalculateParens(String currentText) {
    final openCount = '('.allMatches(currentText).length;
    final closeCount = ')'.allMatches(currentText).length;
    _parenBalance = openCount - closeCount;
  }

  void _updateText(String newText) {
    // Let UI settle, then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (textScrollController.hasClients) {
        textScrollController.animateTo(
          textScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }
    });

    notifyListeners();
  }

  // --- Evaluation ---

  void _evaluate() {
    String evalExpr = controller.text;

    if (evalExpr.isEmpty) return;

    // Auto-close parentheses
    if (_parenBalance > 0) {
      evalExpr += ')' * _parenBalance;
    }

    // Handle memory math M+ / M-
    if (evalExpr.contains('M+') || evalExpr.contains('M-')) {
      _handleMemoryMath(evalExpr);
      return;
    }

    final result = calculator.evaluate(
      evalExpr,
      angleMode,
      EvalContext(functions: functions.functions, variables: _memory),
    );

    if (result is EvalSuccess) {
      double val = result.value;
      _memory['Ans'] = val;
      display = _formatNumber(val);

      // Optional: Update expression to match result?
      // Standard calculators usually keep the expression until new input.
      // But clearing for next input is handled by UI logic often.
      // For now, we leave the expression as is.
    } else {
      display = 'Math ERROR';
    }
    notifyListeners();
  }

  void _handleMemoryMath(String expr) {
    bool isAdd = expr.contains('M+');
    // Simple logic: assume the expression is everything before M+
    // In real casio, M+ evaluates the current expr and adds to M.
    String cleanExpr = expr.replaceAll('M+', '').replaceAll('M-', '');
    if (cleanExpr.isEmpty) cleanExpr = display; // Use previous result if empty

    final result = calculator.evaluate(
      cleanExpr,
      angleMode,
      EvalContext(functions: functions.functions, variables: _memory),
    );

    if (result is EvalSuccess) {
      double val = result.value;
      if (isAdd) {
        _memory['M'] = (_memory['M'] ?? 0) + val;
      } else {
        _memory['M'] = (_memory['M'] ?? 0) - val;
      }
      display = 'M = ${_memory['M']}';
      controller.clear(); // Clear input after memory op
      _parenBalance = 0;
    } else {
      display = 'Math ERROR';
    }
    notifyListeners();
  }

  String _formatNumber(double val) {
    if (val.isNaN) return 'Math ERROR';
    if (val.isInfinite) return val > 0 ? '∞' : '-∞';
    if (val.abs() >= 1e10 || (val.abs() < 1e-3 && val != 0)) {
      return val.toStringAsExponential(9).replaceFirst(RegExp(r'0+e'), 'e');
    }
    String str = val.toStringAsFixed(10);
    return str.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  // --- Toggles & Setup ---

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
      // Map hyp functions
      if (primary == 'sin')
        toInput = 'sinh';
      else if (primary == 'cos')
        toInput = 'cosh';
      else if (primary == 'tan')
        toInput = 'tanh';
      else if (shift == 'sin⁻¹')
        toInput = 'asinh';
      else if (shift == 'cos⁻¹')
        toInput = 'acosh';
      else if (shift == 'tan⁻¹')
        toInput = 'atanh';
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
