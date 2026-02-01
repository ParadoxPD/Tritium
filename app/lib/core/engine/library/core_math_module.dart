import 'dart:math' as math;

import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/engine/library/library_module.dart';
import 'package:app/core/eval_types.dart';
import 'package:app/core/eval_context.dart';

/// The basic math functions (sin, cos, log, etc.)
class CoreMathModule extends LibraryModule {
  @override
  Map<String, Value> get constants => {
    'π': NumberValue(math.pi),
    'e': NumberValue(math.e),
    'i': const ComplexValue(0, 1),
  };

  @override
  Map<String, NativeFunction> get functions => {
    // Trigonometric functions (input angle)
    'sin': NativeFunction(1, (args, context) {
      final radians = _toRadians(args[0].toDouble() ?? 0, context);
      return NumberValue(math.sin(radians));
    }),

    'cos': NativeFunction(1, (args, context) {
      final radians = _toRadians(args[0].toDouble() ?? 0, context);
      return NumberValue(math.cos(radians));
    }),

    'tan': NativeFunction(1, (args, context) {
      final radians = _toRadians(args[0].toDouble() ?? 0, context);
      return NumberValue(math.tan(radians));
    }),

    // Inverse trig functions (output angle)
    'asin': NativeFunction(1, (args, context) {
      final radians = math.asin(args[0].toDouble() ?? 0);
      return NumberValue(_fromRadians(radians, context));
    }),

    'acos': NativeFunction(1, (args, context) {
      final radians = math.acos(args[0].toDouble() ?? 0);
      return NumberValue(_fromRadians(radians, context));
    }),

    'atan': NativeFunction(1, (args, context) {
      final radians = math.atan(args[0].toDouble() ?? 0);
      return NumberValue(_fromRadians(radians, context));
    }),

    // Hyperbolic functions (no angle conversion needed)
    'sinh': NativeFunction(1, (args, context) {
      return NumberValue(_sinh(args[0].toDouble() ?? 0));
    }),

    'cosh': NativeFunction(1, (args, context) {
      return NumberValue(_cosh(args[0].toDouble() ?? 0));
    }),

    'tanh': NativeFunction(1, (args, context) {
      return NumberValue(_tanh(args[0].toDouble() ?? 0));
    }),

    'asinh': NativeFunction(1, (args, context) {
      return NumberValue(_asinh(args[0].toDouble() ?? 0));
    }),

    'acosh': NativeFunction(1, (args, context) {
      return NumberValue(_acosh(args[0].toDouble() ?? 0));
    }),

    'atanh': NativeFunction(1, (args, context) {
      return NumberValue(_atanh(args[0].toDouble() ?? 0));
    }),

    // Other math functions
    'sqrt': NativeFunction(1, (args, context) {
      double val = args[0].toDouble() ?? 0;
      if (val < 0) return ComplexValue(0, math.sqrt(-val));
      return NumberValue(math.sqrt(val));
    }),

    'ln': NativeFunction(1, (args, context) {
      return NumberValue(math.log(args[0].toDouble() ?? 0));
    }),

    'log': NativeFunction(1, (args, context) {
      return NumberValue(math.log(args[0].toDouble() ?? 0) / math.ln10);
    }),

    'abs': NativeFunction(1, (args, context) {
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

  // --- Angle Conversion Helpers ---

  /// Convert input angle to radians based on context mode
  double _toRadians(double angle, EvalContext? context) {
    if (context?.angleMode == AngleMode.degrees) {
      return angle * math.pi / 180.0;
    }
    return angle; // Already in radians
  }

  /// Convert radians to output angle based on context mode
  double _fromRadians(double radians, EvalContext? context) {
    if (context?.angleMode == AngleMode.degrees) {
      return radians * 180.0 / math.pi;
    }
    return radians; // Keep in radians
  }

  // --- Hyperbolic Functions ---

  double _sinh(double x) {
    final ex = math.exp(x);
    final emx = math.exp(-x);
    return (ex - emx) / 2.0;
  }

  double _cosh(double x) {
    final ex = math.exp(x);
    final emx = math.exp(-x);
    return (ex + emx) / 2.0;
  }

  double _tanh(double x) {
    final ex = math.exp(x);
    final emx = math.exp(-x);
    return (ex - emx) / (ex + emx);
  }

  double _asinh(double x) {
    return math.log(x + math.sqrt(x * x + 1));
  }

  double _acosh(double x) {
    if (x < 1) {
      throw Exception('acosh domain error: x must be ≥ 1');
    }
    return math.log(x + math.sqrt(x - 1) * math.sqrt(x + 1));
  }

  double _atanh(double x) {
    if (x <= -1 || x >= 1) {
      throw Exception('atanh domain error: |x| must be < 1');
    }
    return 0.5 * math.log((1 + x) / (1 - x));
  }
}
