import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/engine/library/core_math_module.dart';
import 'package:app/core/engine/library/library_module.dart';
import 'package:app/core/engine/library/matrix_module.dart';
import 'package:app/core/engine/library/modulo_module.dart';
import 'package:app/core/eval_types.dart';

/// Defines a module of functions (e.g., Geometry, Finance, Core)
class StandardLibrary {
  static final List<LibraryModule> _modules = [
    CoreMathModule(),
    MatrixMathModule(),
    ModuloMathModule(),
    // Future: GeometryModule(),
    // Future: FinanceModule(),
  ];

  /// Aggregates all functions from all modules
  static Map<String, NativeFunction> get allFunctions {
    final map = <String, NativeFunction>{};
    for (var module in _modules) {
      map.addAll(module.functions);
    }
    return map;
  }

  /// Aggregates all constants
  static Map<String, Value> get allConstants {
    final map = <String, Value>{};
    for (var module in _modules) {
      map.addAll(module.constants);
    }
    return map;
  }
}
