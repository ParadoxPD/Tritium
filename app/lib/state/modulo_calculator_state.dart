import 'package:flutter/foundation.dart';
import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';

enum ModuloOperation {
  add,
  subtract,
  multiply,
  divide,
  power,
  modularInverse,
  gcd,
  lcm,
  extendedGcd,
}

class ModuloCalculatorState extends ChangeNotifier {
  final EvaluationEngine _engine;
  final EvalContext _context = const EvalContext();

  // Calculator display and input
  String _display = '0';
  String _expression = '';
  int _modulus = 7;

  // Current operation state
  double? _firstOperand;
  ModuloOperation? _pendingOperation;
  bool _shouldClearDisplay = false;

  // Results
  String? _result;
  String? _error;
  String? _message;

  ModuloCalculatorState(this._engine);

  // Getters
  String get display => _display;
  String get expression => _expression;
  int get modulus => _modulus;
  String? get result => _result;
  String? get error => _error;
  String? get message => _message;

  // --- Calculator Input Methods ---

  void appendDigit(String digit) {
    if (_shouldClearDisplay) {
      _display = digit;
      _shouldClearDisplay = false;
    } else {
      _display = _display == '0' ? digit : _display + digit;
    }
    _clearResults();
    notifyListeners();
  }

  void appendDecimal() {
    if (_shouldClearDisplay) {
      _display = '0.';
      _shouldClearDisplay = false;
    } else if (!_display.contains('.')) {
      _display += '.';
    }
    _clearResults();
    notifyListeners();
  }

  void toggleSign() {
    if (_display != '0') {
      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    }
    _clearResults();
    notifyListeners();
  }

  void clear() {
    _display = '0';
    _expression = '';
    _firstOperand = null;
    _pendingOperation = null;
    _shouldClearDisplay = false;
    _clearResults();
    notifyListeners();
  }

  void backspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
    _clearResults();
    notifyListeners();
  }

  void setModulus(int mod) {
    if (mod > 0) {
      _modulus = mod;
      _clearResults();
      notifyListeners();
    }
  }

  // --- Operation Methods ---

  void performOperation(ModuloOperation op) {
    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    if (_firstOperand == null) {
      _firstOperand = currentValue;
      _pendingOperation = op;
      _expression = '$_display ${_getOperationSymbol(op)} ';
      _shouldClearDisplay = true;
    } else if (_pendingOperation != null) {
      _executeOperation();
      _firstOperand = double.tryParse(_display);
      _pendingOperation = op;
      _expression = '$_display ${_getOperationSymbol(op)} ';
      _shouldClearDisplay = true;
    }

    _clearResults();
    notifyListeners();
  }

  void equals() {
    if (_firstOperand != null && _pendingOperation != null) {
      _executeOperation();
      _firstOperand = null;
      _pendingOperation = null;
      _shouldClearDisplay = true;
    }
    notifyListeners();
  }

  // --- Direct Operations (without calculator flow) ---

  void calculateModularInverse() {
    _clearResults();
    final a = double.tryParse(_display)?.toInt();
    if (a == null) {
      _error = 'Invalid input';
      notifyListeners();
      return;
    }

    final expr = 'modinv($a, $_modulus)';
    _evaluateExpression(expr, 'Modular Inverse of $a mod $_modulus');
  }

  void calculateGCD() {
    _clearResults();
    if (_firstOperand == null) {
      _error = 'Enter two numbers';
      notifyListeners();
      return;
    }

    final a = _firstOperand!.toInt();
    final b = double.tryParse(_display)?.toInt();
    if (b == null) {
      _error = 'Invalid input';
      notifyListeners();
      return;
    }

    final expr = 'gcd($a, $b)';
    _evaluateExpression(expr, 'GCD($a, $b)');
    _firstOperand = null;
  }

  void calculateLCM() {
    _clearResults();
    if (_firstOperand == null) {
      _error = 'Enter two numbers';
      notifyListeners();
      return;
    }

    final a = _firstOperand!.toInt();
    final b = double.tryParse(_display)?.toInt();
    if (b == null) {
      _error = 'Invalid input';
      notifyListeners();
      return;
    }

    final expr = 'lcm($a, $b)';
    _evaluateExpression(expr, 'LCM($a, $b)');
    _firstOperand = null;
  }

  void calculateExtendedGCD() {
    _clearResults();
    if (_firstOperand == null) {
      _error = 'Enter two numbers';
      notifyListeners();
      return;
    }

    final a = _firstOperand!.toInt();
    final b = double.tryParse(_display)?.toInt();
    if (b == null) {
      _error = 'Invalid input';
      notifyListeners();
      return;
    }

    final expr = 'extgcd($a, $b)';
    _evaluateExpression(expr, 'Extended GCD($a, $b)');
    _firstOperand = null;
  }

  void reduceModulo() {
    _clearResults();
    final a = double.tryParse(_display)?.toInt();
    if (a == null) {
      _error = 'Invalid input';
      notifyListeners();
      return;
    }

    final expr = '$a % $_modulus';
    final result = _engine.evaluate(expr, _context);

    if (result is EngineSuccess) {
      if (result.value is NumberValue) {
        final value = (result.value as NumberValue).value;
        _display = value.toInt().toString();
        _result = '$a mod $_modulus = ${value.toInt()}';
        _expression = '';
      }
    } else if (result is EngineError) {
      _error = result.message;
    }

    notifyListeners();
  }

  // --- Private Helper Methods ---

  void _executeOperation() {
    if (_firstOperand == null || _pendingOperation == null) return;

    final a = _firstOperand!.toInt();
    final b = double.tryParse(_display)?.toInt();
    if (b == null) {
      _error = 'Invalid input';
      notifyListeners();
      return;
    }

    String expr;
    String description;

    switch (_pendingOperation!) {
      case ModuloOperation.add:
        expr = '($a + $b) % $_modulus';
        description = '($a + $b) mod $_modulus';
        break;
      case ModuloOperation.subtract:
        expr = '($a - $b) % $_modulus';
        description = '($a - $b) mod $_modulus';
        break;
      case ModuloOperation.multiply:
        expr = '($a * $b) % $_modulus';
        description = '($a × $b) mod $_modulus';
        break;
      case ModuloOperation.divide:
        expr = 'moddiv($a, $b, $_modulus)';
        description = '($a ÷ $b) mod $_modulus';
        break;
      case ModuloOperation.power:
        expr = 'modpow($a, $b, $_modulus)';
        description = '$a^$b mod $_modulus';
        break;
      default:
        return;
    }

    _evaluateExpression(expr, description);
  }

  void _evaluateExpression(String expr, String description) {
    final result = _engine.evaluate(expr, _context);

    if (result is EngineSuccess) {
      if (result.value is NumberValue) {
        final value = (result.value as NumberValue).value;
        _display = value.toInt().toString();
        _result = description;
        _expression = '';
      } else if (result.value is ListValue) {
        // For extended GCD which returns [gcd, x, y]
        final list = result.value as ListValue;
        _message =
            '$description\n${list.values.map((v) => v.toDisplayString()).join(', ')}';
        _expression = '';
      } else {
        _display = result.value.toDisplayString();
        _result = description;
        _expression = '';
      }
    } else if (result is EngineError) {
      _error = result.message;
      _expression = '';
    }
  }

  String _getOperationSymbol(ModuloOperation op) {
    return switch (op) {
      ModuloOperation.add => '+',
      ModuloOperation.subtract => '−',
      ModuloOperation.multiply => '×',
      ModuloOperation.divide => '÷',
      ModuloOperation.power => '^',
      _ => '',
    };
  }

  void _clearResults() {
    _result = null;
    _error = null;
    _message = null;
  }
}
