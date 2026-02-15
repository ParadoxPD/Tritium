import 'package:flutter/foundation.dart';
import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';
import 'package:app/services/logging_service.dart';

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
  final LoggerService _logger = LoggerService();

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

  void setError(String message) {
    _error = message;
    notifyListeners();
  }

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
      _logger.debug('Modulo calculator modulus updated to $_modulus');
      _clearResults();
      notifyListeners();
    }
  }

  void setModulusFromInput(String input) {
    _trySetModulusFromInput(input, strict: true);
  }

  void updateModulusFromInput(String input) {
    _trySetModulusFromInput(input, strict: false);
  }

  void _trySetModulusFromInput(String input, {required bool strict}) {
    final parsed = int.tryParse(input.trim());
    if (parsed == null || parsed == 0) {
      if (strict) {
        _error = 'Modulus must be a non-zero integer';
        notifyListeners();
      }
      return;
    }

    _modulus = parsed.abs();
    _clearResults();
    notifyListeners();
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
    } else {
      reduceModulo();
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

  void calculateModularInverseFor(int a) {
    _clearResults();
    final expr = 'modinv($a, $_modulus)';
    _evaluateExpression(expr, 'Modular Inverse of $a mod $_modulus');
    notifyListeners();
  }

  void calculateModPowerFor(int base, int exponent) {
    _clearResults();
    final expr = 'modpow($base, $exponent, $_modulus)';
    _evaluateExpression(expr, '$base^$exponent mod $_modulus');
    notifyListeners();
  }

  void calculateGCDFor(int a, int b) {
    _clearResults();
    final expr = 'gcd($a, $b)';
    _evaluateExpression(expr, 'GCD($a, $b)');
    notifyListeners();
  }

  void calculateLCMFor(int a, int b) {
    _clearResults();
    final expr = 'lcm($a, $b)';
    _evaluateExpression(expr, 'LCM($a, $b)');
    notifyListeners();
  }

  void calculateExtendedGCDFor(int a, int b) {
    _clearResults();
    final expr = 'extgcd($a, $b)';
    _evaluateExpression(expr, 'Extended GCD($a, $b)');
    notifyListeners();
  }

  void checkCongruenceFor(int a, int b) {
    _clearResults();
    final expr = '(($a - $b) % $_modulus) == 0';
    _evaluateExpression(expr, '$a ≡ $b (mod $_modulus)');
    notifyListeners();
  }

  void calculateEulerTotientFor(int n) {
    _clearResults();
    final expr = 'phi($n)';
    _evaluateExpression(expr, 'Euler φ($n)');
    notifyListeners();
  }

  void calculateMatrixInverseModulo(String matrixLiteral) {
    _clearResults();
    final expr = 'modmatinv($matrixLiteral, $_modulus)';
    _evaluateExpression(expr, 'Matrix inverse mod $_modulus');
    notifyListeners();
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
      _error = result.toString();
    }

    notifyListeners();
  }

  // --- Private Helper Methods ---

  void _executeOperation() {
    if (_firstOperand == null || _pendingOperation == null) return;

    final a = _parseInteger(_firstOperand!.toString());
    final b = _parseInteger(_display);
    if (a == null || b == null) {
      _error = 'Modulo operations require integer inputs';
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
    _logger.trace('Modulo eval: $expr');
    final result = _engine.evaluate(expr, _context);

    if (result is EngineSuccess) {
      if (result.value is NumberValue) {
        final value = (result.value as NumberValue).value;
        final intValue = value.toInt();
        _display = intValue.toString();
        _result = '$description = $intValue';
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
      _error = result.toString();
      _expression = '';
      _logger.warn('Modulo eval failed: ${result.toString()}');
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

  int? _parseInteger(String value) {
    final number = double.tryParse(value);
    if (number == null || !number.isFinite || number % 1 != 0) return null;
    return number.toInt();
  }
}
