import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:flutter/material.dart';

class CalculatorState extends ChangeNotifier {
  final EvaluationEngine _engine;
  final TextEditingController controller = TextEditingController();
  final ScrollController textScrollController = ScrollController();

  EvalContext _context;
  String _display = '0';
  bool isShift = false;
  bool isAlpha = false;
  bool isHyp = false;

  CalculatorState(this._engine) : _context = const EvalContext();

  String get display => _display;
  AngleMode get angleMode => _context.angleMode;

  void setAngleMode(AngleMode mode) {
    _context = _context.copyWith(angleMode: mode);
    notifyListeners();
  }

  void toggleAngleMode() {
    setAngleMode(
      _context.angleMode == AngleMode.radians
          ? AngleMode.degrees
          : AngleMode.radians,
    );
  }

  void handleButtonPress({
    required String primary,
    String? shift,
    String? alpha,
  }) {
    String token = primary;

    // Determine which token to use based on mode
    if (isShift && shift != null) {
      token = shift;
      isShift = false; // Clear shift after use
    } else if (isAlpha && alpha != null) {
      token = alpha;
      isAlpha = false; // Clear alpha after use
    }

    _insertToken(token);
  }

  void evaluate() {
    final input = controller.text.trim();
    if (input.isEmpty) {
      _display = '0';
      notifyListeners();
      return;
    }

    final result = _engine.evaluate(input, _context);

    if (result is EngineSuccess) {
      _display = result.value.toDisplayString();
      _context = result.context; // Use updated context from engine
    } else if (result is EngineError) {
      _display = 'Error: ${result.message}';
    }

    notifyListeners();
  }

  void _insertToken(String token) {
    token = switch (token) {
      "³√" => "3√",
      "ⁿ√" => "√",
      _ => token,
    };
    final cursorPos = controller.selection.base.offset;
    final text = controller.text;

    if (cursorPos == -1) {
      // No selection, append
      controller.text = text + token;
    } else {
      // Insert at cursor
      final before = text.substring(0, cursorPos);
      final after = text.substring(cursorPos);
      controller.text = before + token + after;

      // Move cursor after inserted token
      controller.selection = TextSelection.collapsed(
        offset: cursorPos + token.length,
      );
    }
    _scrollToEnd();
    notifyListeners();
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

  void clear() {
    controller.clear();
    _display = '0';
    notifyListeners();
  }

  void delete() {
    final cursorPos = controller.selection.base.offset;
    if (cursorPos <= 0) return;

    final text = controller.text;
    final before = text.substring(0, cursorPos - 1);
    final after = text.substring(cursorPos);
    controller.text = before + after;

    controller.selection = TextSelection.collapsed(offset: cursorPos - 1);

    notifyListeners();
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

  @override
  void dispose() {
    controller.dispose();
    textScrollController.dispose();
    super.dispose();
  }
}
