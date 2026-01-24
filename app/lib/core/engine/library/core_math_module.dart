import 'dart:math' as math;

import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/engine/library/library_module.dart';
import 'package:app/core/eval_types.dart';

/// The basic math functions (sin, cos, log, etc.)
class CoreMathModule extends LibraryModule {
  @override
  Map<String, Value> get constants => {
    'pi': NumberValue(math.pi),
    'e': NumberValue(math.e),
    'i': const ComplexValue(0, 1),
  };

  @override
  Map<String, NativeFunction> get functions => {
    'sin': NativeFunction(
      1,
      (args) => NumberValue(math.sin(args[0].toDouble() ?? 0)),
    ),
    'cos': NativeFunction(
      1,
      (args) => NumberValue(math.cos(args[0].toDouble() ?? 0)),
    ),
    'tan': NativeFunction(
      1,
      (args) => NumberValue(math.tan(args[0].toDouble() ?? 0)),
    ),
    'sqrt': NativeFunction(1, (args) {
      double val = args[0].toDouble() ?? 0;
      if (val < 0) return ComplexValue(0, math.sqrt(-val));
      return NumberValue(math.sqrt(val));
    }),
    'ln': NativeFunction(
      1,
      (args) => NumberValue(math.log(args[0].toDouble() ?? 0)),
    ),
    'log': NativeFunction(
      1,
      (args) => NumberValue(math.log(args[0].toDouble() ?? 0) / math.ln10),
    ),
    'abs': NativeFunction(1, (args) {
      final val = args[0];
      if (val is NumberValue) return NumberValue(val.value.abs());
      if (val is ComplexValue) {
        return NumberValue(
          math.sqrt(val.real * val.real + val.imaginary * val.imaginary),
        );
      }
      return val;
    }),
  };
}
