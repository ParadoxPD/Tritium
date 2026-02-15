import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/engine/evaluator/runtime_errors.dart';
import 'package:app/core/engine/library/library_module.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_types.dart';

class ModuloMathModule extends LibraryModule {
  @override
  Map<String, Value> get constants => {};

  @override
  Map<String, NativeFunction> get functions => {
    'modinv': NativeFunction(2, (args, context) {
      final a = _asInteger(args[0], 'a', 'modinv');
      final m = _asInteger(args[1], 'm', 'modinv');

      if (m <= 0) {
        throw RuntimeError(
          message: 'Modulus must be positive',
          type: ErrorType.domainError,
          operation: 'modinv',
          hint: 'Use m > 0.',
        );
      }

      final result = _modularInverse(a, m);
      if (result == null) {
        throw RuntimeError(
          message: 'Modular inverse does not exist because gcd($a, $m) != 1',
          type: ErrorType.domainError,
          operation: 'modinv',
          hint: 'Ensure a and m are coprime.',
        );
      }

      return NumberValue(result.toDouble());
    }),

    'modpow': NativeFunction(3, (args, context) {
      final a = _asInteger(args[0], 'base', 'modpow');
      final b = _asInteger(args[1], 'exponent', 'modpow');
      final m = _asInteger(args[2], 'modulus', 'modpow');

      if (m <= 0) {
        throw RuntimeError(
          message: 'Modulus must be positive',
          type: ErrorType.domainError,
          operation: 'modpow',
          hint: 'Use m > 0.',
        );
      }
      if (b < 0) {
        throw RuntimeError(
          message: 'Exponent must be non-negative',
          type: ErrorType.domainError,
          operation: 'modpow',
        );
      }

      final result = _modularPower(a, b, m);
      return NumberValue(result.toDouble());
    }),

    'moddiv': NativeFunction(3, (args, context) {
      final a = _asInteger(args[0], 'a', 'moddiv');
      final b = _asInteger(args[1], 'b', 'moddiv');
      final m = _asInteger(args[2], 'm', 'moddiv');

      if (m <= 0) {
        throw RuntimeError(
          message: 'Modulus must be positive',
          type: ErrorType.domainError,
          operation: 'moddiv',
          hint: 'Use m > 0.',
        );
      }

      final bInv = _modularInverse(b, m);
      if (bInv == null) {
        throw RuntimeError(
          message: 'Cannot divide: modular inverse of $b does not exist',
          type: ErrorType.domainError,
          operation: 'moddiv',
          hint: 'b and m must be coprime.',
        );
      }

      final result = _normalizeModulo(a * bInv, m);
      return NumberValue(result.toDouble());
    }),

    'gcd': NativeFunction(2, (args, context) {
      final a = _asInteger(args[0], 'a', 'gcd').abs();
      final b = _asInteger(args[1], 'b', 'gcd').abs();

      final result = _gcd(a, b);
      return NumberValue(result.toDouble());
    }),

    'lcm': NativeFunction(2, (args, context) {
      final a = _asInteger(args[0], 'a', 'lcm').abs();
      final b = _asInteger(args[1], 'b', 'lcm').abs();

      if (a == 0 || b == 0) return NumberValue(0);

      final result = (a * b) ~/ _gcd(a, b);
      return NumberValue(result.toDouble());
    }),

    'extgcd': NativeFunction(2, (args, context) {
      final a = _asInteger(args[0], 'a', 'extgcd');
      final b = _asInteger(args[1], 'b', 'extgcd');

      final result = _extendedGCD(a, b);
      return ListValue([
        NumberValue(result[0].toDouble()),
        NumberValue(result[1].toDouble()),
        NumberValue(result[2].toDouble()),
      ]);
    }),

    'phi': NativeFunction(1, (args, context) {
      final n = _asInteger(args[0], 'n', 'phi');
      if (n <= 0) {
        throw RuntimeError(
          message: 'n must be positive',
          type: ErrorType.domainError,
          operation: 'phi',
          hint: 'Use n > 0.',
        );
      }
      return NumberValue(_eulerTotient(n).toDouble());
    }),

    'modmatinv': NativeFunction(2, (args, context) {
      if (args[0] is! MatrixValue) {
        throw RuntimeError(
          message: 'First argument must be a matrix',
          type: ErrorType.typeMismatch,
          operation: 'modmatinv',
        );
      }
      final m = _asInteger(args[1], 'modulus', 'modmatinv');
      if (m <= 0) {
        throw RuntimeError(
          message: 'Modulus must be positive',
          type: ErrorType.domainError,
          operation: 'modmatinv',
          hint: 'Use m > 0.',
        );
      }

      final matrix = args[0] as MatrixValue;
      final inverse = _matrixModularInverse(matrix, m);
      return MatrixValue(
        inverse.map((row) => row.map((v) => v.toDouble()).toList()).toList(),
      );
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
    final gcd = result[0].abs();
    final x = result[1];

    if (gcd != 1) {
      return null;
    }

    return _normalizeModulo(x, m);
  }

  static int _modularPower(int base, int exponent, int modulus) {
    if (modulus == 1) return 0;

    int result = 1;
    base = _normalizeModulo(base, modulus);

    while (exponent > 0) {
      if (exponent % 2 == 1) {
        result = _normalizeModulo(result * base, modulus);
      }
      exponent = exponent >> 1;
      base = _normalizeModulo(base * base, modulus);
    }

    return result;
  }

  static int _asInteger(Value value, String argName, String operation) {
    if (value is! NumberValue) {
      throw RuntimeError(
        message: '$argName must be numeric',
        type: ErrorType.typeMismatch,
        operation: operation,
      );
    }

    final raw = value.value;
    if (!raw.isFinite || raw % 1 != 0) {
      throw RuntimeError(
        message: '$argName must be an integer',
        type: ErrorType.typeMismatch,
        operation: operation,
        hint: 'Use whole numbers for modular arithmetic.',
      );
    }

    return raw.toInt();
  }

  static int _normalizeModulo(int value, int modulus) {
    final m = modulus.abs();
    if (m == 0) return value;
    return ((value % m) + m) % m;
  }

  static int _eulerTotient(int n) {
    int result = n;
    int x = n;

    for (int p = 2; p * p <= x; p++) {
      if (x % p == 0) {
        while (x % p == 0) {
          x ~/= p;
        }
        result -= result ~/ p;
      }
    }

    if (x > 1) {
      result -= result ~/ x;
    }

    return result;
  }

  static List<List<int>> _matrixModularInverse(MatrixValue matrix, int modulus) {
    if (matrix.rows != matrix.cols) {
      throw RuntimeError(
        message: 'Matrix must be square',
        type: ErrorType.dimensionMismatch,
        operation: 'modmatinv',
      );
    }

    final intData = matrix.data
        .map(
          (row) => row.map((v) {
            if (!v.isFinite || v % 1 != 0) {
              throw RuntimeError(
                message: 'Matrix entries must be integers',
                type: ErrorType.typeMismatch,
                operation: 'modmatinv',
              );
            }
            return v.toInt();
          }).toList(),
        )
        .toList();

    final det = _determinantInt(intData);
    final detInv = _modularInverse(_normalizeModulo(det, modulus), modulus);

    if (detInv == null) {
      throw RuntimeError(
        message: 'Matrix is not invertible under this modulus',
        type: ErrorType.domainError,
        operation: 'modmatinv',
        hint: 'det(A) must be coprime with modulus.',
      );
    }

    final adj = _adjugate(intData);
    return List.generate(
      matrix.rows,
      (i) => List.generate(
        matrix.cols,
        (j) => _normalizeModulo(detInv * adj[i][j], modulus),
      ),
    );
  }

  static int _determinantInt(List<List<int>> matrix) {
    final n = matrix.length;
    if (n == 1) return matrix[0][0];
    if (n == 2) {
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    }

    int det = 0;
    for (int col = 0; col < n; col++) {
      final sign = (col % 2 == 0) ? 1 : -1;
      det += sign * matrix[0][col] * _determinantInt(_minor(matrix, 0, col));
    }
    return det;
  }

  static List<List<int>> _adjugate(List<List<int>> matrix) {
    final n = matrix.length;
    if (n == 1) return [[1]];

    final cofactors = List.generate(n, (_) => List.filled(n, 0));
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        final sign = ((i + j) % 2 == 0) ? 1 : -1;
        cofactors[i][j] = sign * _determinantInt(_minor(matrix, i, j));
      }
    }

    // Transpose cofactor matrix
    return List.generate(
      n,
      (i) => List.generate(n, (j) => cofactors[j][i]),
    );
  }

  static List<List<int>> _minor(List<List<int>> matrix, int row, int col) {
    final result = <List<int>>[];
    for (int i = 0; i < matrix.length; i++) {
      if (i == row) continue;
      final newRow = <int>[];
      for (int j = 0; j < matrix.length; j++) {
        if (j == col) continue;
        newRow.add(matrix[i][j]);
      }
      result.add(newRow);
    }
    return result;
  }
}
