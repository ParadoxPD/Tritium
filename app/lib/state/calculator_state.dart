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

  final TextEditingController controller = TextEditingController();
  final ScrollController textScrollController = ScrollController();

  String display = '0';
  bool isShift = false;
  bool isAlpha = false;
  bool isHyp = false;

  // Display modes
  AngleMode angleMode = AngleMode.rad;
  BaseMode baseMode = BaseMode.decimal;
  DisplayMode displayMode = DisplayMode.normal;
  bool exactMode = false; // Show fractions when possible

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

  // Advanced storage
  final Map<String, Matrix> _matrices = {};
  final Map<String, Complex> _complexVars = {};

  bool _isStoreMode = false;
  bool _isRecallMode = false;
  int _parenBalance = 0;

  CalculatorState(this.calculator, this.functions) {
    _loadPrefs();
  }

  @override
  void dispose() {
    controller.dispose();
    textScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final angleName = prefs.getString('angle_mode');
    angleMode = AngleMode.values.firstWhere(
      (e) => e.name == angleName,
      orElse: () => AngleMode.rad,
    );

    final baseName = prefs.getString('base_mode');
    baseMode = BaseMode.values.firstWhere(
      (e) => e.name == baseName,
      orElse: () => BaseMode.decimal,
    );

    final displayName = prefs.getString('display_mode');
    displayMode = DisplayMode.values.firstWhere(
      (e) => e.name == displayName,
      orElse: () => DisplayMode.normal,
    );

    exactMode = prefs.getBool('exact_mode') ?? false;

    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('angle_mode', angleMode.name);
    await prefs.setString('base_mode', baseMode.name);
    await prefs.setString('display_mode', displayMode.name);
    await prefs.setBool('exact_mode', exactMode);
  }

  Map<String, double> get memory => _memory;
  Map<String, Matrix> get matrices => _matrices;
  Map<String, Complex> get complexVars => _complexVars;
  bool get isStoreMode => _isStoreMode;

  // ===================== INPUT HANDLING =====================

  void input(String value) {
    // Special modes
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

    // Store mode
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

    // Recall mode
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

    if (value == 'RESET') {
      _reset();
      _memory.updateAll((key, value) => 0.0);
      _matrices.clear();
      _complexVars.clear();
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
      _moveCursor(-1);
      return;
    }

    if (value == '→') {
      _moveCursor(1);
      return;
    }

    // Mode toggles
    if (value == 'DRG' || value == 'RAD' || value == 'DEG') {
      toggleAngleMode();
      return;
    }

    if (value == 'ENG') {
      cycleDisplayMode();
      return;
    }

    if (value == 'S⇔D') {
      exactMode = !exactMode;
      _savePrefs();
      // Re-evaluate to show in new mode
      if (display != '0') _evaluate();
      return;
    }

    // Insert text
    String textToInsert = _mapButtonToSyntax(value);
    _insertAtCursor(textToInsert);
  }

  void _insertAtCursor(String text) {
    final selection = controller.selection;
    final currentText = controller.text;

    String newText;
    int newCursorPos;

    if (selection.start >= 0) {
      newText = currentText.replaceRange(selection.start, selection.end, text);
      newCursorPos = selection.start + text.length;
    } else {
      newText = currentText + text;
      newCursorPos = newText.length;
    }

    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: newCursorPos);

    final openCount = '('.allMatches(text).length;
    final closeCount = ')'.allMatches(text).length;
    _parenBalance += (openCount - closeCount);

    notifyListeners();
    _scrollToEnd();
  }

  void _delete() {
    final text = controller.text;
    final selection = controller.selection;

    if (text.isEmpty) return;

    if (!selection.isCollapsed) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: selection.start);
      _recalculateParens(newText);
      notifyListeners();
      return;
    }

    if (selection.baseOffset <= 0) return;

    int cursor = selection.baseOffset;
    int deleteCount = 1;

    // Smart deletion for multi-char functions
    final patterns = [
      (7, ['asinh(', 'acosh(', 'atanh(']),
      (6, ['deriv(', 'round(']),
      (
        5,
        [
          'asin(',
          'acos(',
          'atan(',
          'sinh(',
          'cosh(',
          'tanh(',
          'sqrt(',
          'cbrt(',
        ],
      ),
      (
        4,
        [
          'sin(',
          'cos(',
          'tan(',
          'log(',
          'pol(',
          'rec(',
          'int(',
          'det(',
          'conj(',
        ],
      ),
      (3, ['ln(', 'Re(', 'Im(']),
    ];

    for (final (len, funcs) in patterns) {
      if (cursor >= len && deleteCount == 1) {
        final sub = text.substring(cursor - len, cursor);
        if (funcs.contains(sub)) {
          deleteCount = len;
          break;
        }
      }
    }

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

  void _recalculateParens(String text) {
    _parenBalance = '('.allMatches(text).length - ')'.allMatches(text).length;
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (textScrollController.hasClients) {
        textScrollController.animateTo(
          textScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ===================== EVALUATION =====================

  void _evaluate() {
    String evalExpr = controller.text;

    if (evalExpr.isEmpty) return;

    // Auto-close parentheses
    if (_parenBalance > 0) {
      evalExpr += ')' * _parenBalance;
    }

    // Handle memory operations
    if (evalExpr.contains('M+') || evalExpr.contains('M-')) {
      _handleMemoryMath(evalExpr);
      return;
    }

    final result = calculator.evaluate(
      evalExpr,
      angleMode,
      EvalContext(
        functions: functions.functions,
        variables: _memory,
        matrices: _matrices,
        complexVars: _complexVars,
        baseMode: baseMode,
        exactMode: exactMode,
      ),
    );

    if (result is EvalSuccess) {
      _memory['Ans'] = result.value;

      // Format based on result type and mode
      if (result.matrix != null) {
        display = _formatMatrix(result.matrix!);
      } else if (result.complex != null) {
        display = result.complex.toString();
      } else if (result.fraction != null && exactMode) {
        display = result.fraction.toString();
      } else {
        display = _formatNumber(result.value);
      }
    } else if (result is EvalError) {
      display = result.message;
    }

    notifyListeners();
  }

  void _handleMemoryMath(String expr) {
    bool isAdd = expr.contains('M+');
    String cleanExpr = expr.replaceAll('M+', '').replaceAll('M-', '');
    if (cleanExpr.isEmpty) cleanExpr = display;

    final result = calculator.evaluate(
      cleanExpr,
      angleMode,
      EvalContext(
        functions: functions.functions,
        variables: _memory,
        baseMode: baseMode,
      ),
    );

    if (result is EvalSuccess) {
      if (isAdd) {
        _memory['M'] = (_memory['M'] ?? 0) + result.value;
      } else {
        _memory['M'] = (_memory['M'] ?? 0) - result.value;
      }
      display = 'M = ${_formatNumber(_memory['M']!)}';
      controller.clear();
      _parenBalance = 0;
    } else {
      display = 'Math ERROR';
    }
    notifyListeners();
  }

  // ===================== FORMATTING =====================

  String _formatNumber(double val) {
    if (baseMode != BaseMode.decimal) {
      // For base-N mode, show integer part only
      return NumberFormatter.formatBaseN(val.toInt(), baseMode);
    }

    return NumberFormatter.format(val, mode: displayMode, precision: 10);
  }

  String _formatMatrix(Matrix m) {
    final rows = <String>[];
    for (final row in m.data) {
      final values = row.map((v) => _formatNumber(v)).join(' ');
      rows.add('[$values]');
    }
    return rows.join('\n');
  }

  // ===================== MODE TOGGLES =====================

  void toggleAngleMode() {
    angleMode = angleMode == AngleMode.rad ? AngleMode.deg : AngleMode.rad;
    _savePrefs();
    notifyListeners();
  }

  void setAngleMode(AngleMode mode) {
    angleMode = mode;
    _savePrefs();
    notifyListeners();
  }

  void cycleDisplayMode() {
    final modes = DisplayMode.values;
    final index = modes.indexOf(displayMode);
    displayMode = modes[(index + 1) % modes.length];
    _savePrefs();

    // Re-display in new format
    if (display != '0' && display != 'Math ERROR') {
      final val = double.tryParse(display);
      if (val != null) {
        display = _formatNumber(val);
      }
    }
    notifyListeners();
  }

  void setBaseMode(BaseMode mode) {
    baseMode = mode;
    _savePrefs();
    notifyListeners();
  }

  void toggleExactMode() {
    exactMode = !exactMode;
    _savePrefs();
    if (display != '0') _evaluate();
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

  // ===================== BUTTON HANDLER =====================

  void handleButtonPress({
    required String primary,
    String? shift,
    String? alpha,
  }) {
    String toInput = primary;

    // Handle hyperbolic variants
    if (isHyp) {
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

    // Clear HYP after trig use
    if (isHyp && _isTrigFunction(toInput)) {
      clearHyp();
    }
  }

  bool _isTrigFunction(String s) {
    return s.contains('sin') || s.contains('cos') || s.contains('tan');
  }

  // ===================== BUTTON MAPPING =====================

  String _mapButtonToSyntax(String value) {
    final map = {
      'x⁻¹': '^(-1)',
      'x!': '!',
      '×': '*',
      '÷': '/',
      'xⁿ': '^',
      'x²': '^2',
      'x³': '^3',
      '√': '√',
      '³√': '3√',
      'ⁿ√': '√',
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
      'i': 'i', // Complex unit
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
      // Matrix
      'det': 'det(',
      'T': 'transpose(',
      // Complex
      'Re': 'Re(',
      'Im': 'Im(',
      'conj': 'conj(',
      'arg': 'arg(',
    };

    return map[value] ?? value;
  }
}
