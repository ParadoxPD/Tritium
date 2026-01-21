import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';
import 'package:app/repositories/function_repository.dart';
import '../models/custom_function.dart';

class FunctionService {
  final FunctionRepository _repo;
  final EvaluationEngine _engine;
  final List<CustomFunction> _raw = [];

  // Expose repository for testing or advanced usage if needed
  FunctionRepository get repository => _repo;

  FunctionService(this._repo, this._engine);

  List<CustomFunction> get currentFunctions => List.unmodifiable(_raw);

  Future<void> restore() async {
    final list = await _repo.load();
    setFunctions(list);
  }

  void setFunctions(List<CustomFunction> list) {
    _raw
      ..clear()
      ..addAll(list);

    _repo.save(list);
  }

  /// Evaluate a custom function with given arguments
  Value? evaluateFunction(String name, List<Value> args) {
    final func = _raw.firstWhere(
      (f) => f.name == name,
      orElse: () => throw Exception('Function $name not found'),
    );

    if (args.length != func.parameters.length) {
      throw Exception(
        'Function $name expects ${func.parameters.length} arguments, got ${args.length}',
      );
    }

    // Create a context with parameter bindings
    final variables = <String, Value>{};
    for (int i = 0; i < func.parameters.length; i++) {
      variables[func.parameters[i]] = args[i];
    }

    final context = EvalContext(variables: variables);
    final result = _engine.evaluate(func.formula, context);

    if (result is EngineSuccess) {
      return result.value;
    } else if (result is EngineError) {
      throw Exception('Evaluation error: ${result.message}');
    }

    return null;
  }

  /// Test a formula with dummy values to check if it's valid
  bool validateFormula(String formula, List<String> parameters) {
    // Create test context with dummy parameter values
    final testVars = <String, Value>{};
    for (var param in parameters) {
      testVars[param] = const NumberValue(1.0);
    }

    final testContext = EvalContext(variables: testVars);
    final result = _engine.evaluate(formula, testContext);

    return result is EngineSuccess;
  }

  /// Get validation error for a formula
  String? getValidationError(String formula, List<String> parameters) {
    // Create test context with dummy parameter values
    final testVars = <String, Value>{};
    for (var param in parameters) {
      testVars[param] = const NumberValue(1.0);
    }

    final testContext = EvalContext(variables: testVars);
    final result = _engine.evaluate(formula, testContext);

    if (result is EngineError) {
      return result.message;
    }

    return null;
  }

  /// Check if a function name is already defined
  bool isDefined(String name) {
    return _raw.any((f) => f.name == name);
  }

  /// Delete a function by index
  void deleteFunction(int index) {
    if (index >= 0 && index < _raw.length) {
      _raw.removeAt(index);
      _repo.save(_raw);
    }
  }

  /// Get a function by name
  CustomFunction? getFunction(String name) {
    try {
      return _raw.firstWhere((f) => f.name == name);
    } catch (_) {
      return null;
    }
  }
}
