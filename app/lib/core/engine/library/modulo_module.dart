import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/engine/evaluator/runtime_errors.dart';
import 'package:app/core/engine/library/library_module.dart';
import 'package:app/core/eval_types.dart';

class ModuloMathModule extends LibraryModule {
  @override
  Map<String, Value> get constants => {};

  @override
  Map<String, NativeFunction> get functions => {
    'modinv': NativeFunction(2, (args, context) {
      if (args[0] is! NumberValue || args[1] is! NumberValue) {
        throw RuntimeError('modinv requires two numbers');
      }
      final a = (args[0] as NumberValue).value.toInt();
      final m = (args[1] as NumberValue).value.toInt();

      if (m <= 0) throw RuntimeError('Modulus must be positive');

      final result = _modularInverse(a, m);
      if (result == null) {
        throw RuntimeError('Modular inverse does not exist (gcd($a, $m) ≠ 1)');
      }

      return NumberValue(result.toDouble());
    }),

    'modpow': NativeFunction(3, (args, context) {
      if (args[0] is! NumberValue ||
          args[1] is! NumberValue ||
          args[2] is! NumberValue) {
        throw RuntimeError('modpow requires three numbers');
      }
      final a = (args[0] as NumberValue).value.toInt();
      final b = (args[1] as NumberValue).value.toInt();
      final m = (args[2] as NumberValue).value.toInt();

      if (m <= 0) throw RuntimeError('Modulus must be positive');
      if (b < 0) throw RuntimeError('Exponent must be non-negative');

      final result = _modularPower(a, b, m);
      return NumberValue(result.toDouble());
    }),

    'moddiv': NativeFunction(3, (args, context) {
      if (args[0] is! NumberValue ||
          args[1] is! NumberValue ||
          args[2] is! NumberValue) {
        throw RuntimeError('moddiv requires three numbers');
      }
      final a = (args[0] as NumberValue).value.toInt();
      final b = (args[1] as NumberValue).value.toInt();
      final m = (args[2] as NumberValue).value.toInt();

      if (m <= 0) throw RuntimeError('Modulus must be positive');

      final bInv = _modularInverse(b, m);
      if (bInv == null) {
        throw RuntimeError(
          'Cannot divide: modular inverse of $b does not exist',
        );
      }

      final result = (a * bInv) % m;
      return NumberValue(result.toDouble());
    }),

    'gcd': NativeFunction(2, (args, context) {
      if (args[0] is! NumberValue || args[1] is! NumberValue) {
        throw RuntimeError('gcd requires two numbers');
      }
      final a = (args[0] as NumberValue).value.toInt().abs();
      final b = (args[1] as NumberValue).value.toInt().abs();

      final result = _gcd(a, b);
      return NumberValue(result.toDouble());
    }),

    'lcm': NativeFunction(2, (args, context) {
      if (args[0] is! NumberValue || args[1] is! NumberValue) {
        throw RuntimeError('lcm requires two numbers');
      }
      final a = (args[0] as NumberValue).value.toInt().abs();
      final b = (args[1] as NumberValue).value.toInt().abs();

      if (a == 0 || b == 0) return NumberValue(0);

      final result = (a * b) ~/ _gcd(a, b);
      return NumberValue(result.toDouble());
    }),

    'extgcd': NativeFunction(2, (args, context) {
      if (args[0] is! NumberValue || args[1] is! NumberValue) {
        throw RuntimeError('extgcd requires two numbers');
      }
      final a = (args[0] as NumberValue).value.toInt();
      final b = (args[1] as NumberValue).value.toInt();

      final result = _extendedGCD(a, b);
      return ListValue([
        NumberValue(result[0].toDouble()),
        NumberValue(result[1].toDouble()),
        NumberValue(result[2].toDouble()),
      ]);
    }),
  };

  static int _gcd(int a, int b) {
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  static List<int> _extendedGCD(int a, int b) {
    if (b == 0) {
      return [a, 1, 0];
    }

    int oldR = a, r = b;
    int oldS = 1, s = 0;
    int oldT = 0, t = 1;

    while (r != 0) {
      final quotient = oldR ~/ r;

      int temp = r;
      r = oldR - quotient * r;
      oldR = temp;

      temp = s;
      s = oldS - quotient * s;
      oldS = temp;

      temp = t;
      t = oldT - quotient * t;
      oldT = temp;
    }

    return [oldR, oldS, oldT];
  }

  static int? _modularInverse(int a, int m) {
    final result = _extendedGCD(a, m);
    final gcd = result[0];
    final x = result[1];

    if (gcd != 1) {
      return null;
    }

    return (x % m + m) % m;
  }

  static int _modularPower(int base, int exponent, int modulus) {
    if (modulus == 1) return 0;

    int result = 1;
    base = base % modulus;

    while (exponent > 0) {
      if (exponent % 2 == 1) {
        result = (result * base) % modulus;
      }
      exponent = exponent >> 1;
      base = (base * base) % modulus;
    }

    return result;
  }
}
