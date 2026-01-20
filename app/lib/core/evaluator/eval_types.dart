import 'dart:math' as math;

// ===================== CORE TYPES =====================

enum AngleMode { rad, deg }

enum BaseMode { decimal, binary, octal, hexadecimal }

enum DisplayMode { normal, engineering, scientific }

// ===================== VALUE TYPES =====================

/// Represents a rational number (exact fraction)
class Fraction {
  final int numerator;
  final int denominator;

  const Fraction(this.numerator, this.denominator);

  factory Fraction.fromDouble(double value, {int maxDenominator = 10000}) {
    if (value.isNaN || value.isInfinite) {
      return Fraction(value.isNaN ? 0 : (value > 0 ? 1 : -1), 0);
    }

    final sign = value < 0 ? -1 : 1;
    value = value.abs();

    int a = value.floor();
    double f = value - a;

    if (f < 1e-10) return Fraction(sign * a, 1);

    int h1 = 1, k1 = 0;
    int h2 = 0, k2 = 1;

    while (k2 <= maxDenominator) {
      final b = (1 / f).floor();
      final temp = h1;
      h1 = b * h1 + h2;
      h2 = temp;

      final tempK = k1;
      k1 = b * k1 + k2;
      k2 = tempK;

      if ((f - 1 / b).abs() < 1e-10) break;
      f = 1 / f - b;
    }

    return Fraction(sign * (a * k1 + h1), k1).simplified();
  }

  Fraction simplified() {
    final g = _gcd(numerator.abs(), denominator.abs());
    final sign = (numerator < 0) != (denominator < 0) ? -1 : 1;
    return Fraction(sign * numerator.abs() ~/ g, denominator.abs() ~/ g);
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  double toDouble() => numerator / denominator;

  Fraction operator +(Fraction other) {
    return Fraction(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator,
    ).simplified();
  }

  Fraction operator -(Fraction other) {
    return Fraction(
      numerator * other.denominator - other.numerator * denominator,
      denominator * other.denominator,
    ).simplified();
  }

  Fraction operator *(Fraction other) {
    return Fraction(
      numerator * other.numerator,
      denominator * other.denominator,
    ).simplified();
  }

  Fraction operator /(Fraction other) {
    return Fraction(
      numerator * other.denominator,
      denominator * other.numerator,
    ).simplified();
  }

  Fraction operator -() => Fraction(-numerator, denominator);

  @override
  String toString() {
    if (denominator == 1) return '$numerator';
    return '$numerator/$denominator';
  }

  @override
  bool operator ==(Object other) =>
      other is Fraction &&
      numerator == other.numerator &&
      denominator == other.denominator;

  @override
  int get hashCode => Object.hash(numerator, denominator);
}

/// Complex number support
class Complex {
  final double real;
  final double imag;

  const Complex(this.real, this.imag);

  factory Complex.fromPolar(double r, double theta) {
    return Complex(r * math.cos(theta), r * math.sin(theta));
  }

  double get magnitude => math.sqrt(real * real + imag * imag);
  double get argument => math.atan2(imag, real);

  Complex operator +(Complex other) {
    return Complex(real + other.real, imag + other.imag);
  }

  Complex operator -(Complex other) {
    return Complex(real - other.real, imag - other.imag);
  }

  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imag * other.imag,
      real * other.imag + imag * other.real,
    );
  }

  Complex operator /(Complex other) {
    final denom = other.real * other.real + other.imag * other.imag;
    return Complex(
      (real * other.real + imag * other.imag) / denom,
      (imag * other.real - real * other.imag) / denom,
    );
  }

  Complex operator -() => Complex(-real, -imag);

  Complex conjugate() => Complex(real, -imag);

  @override
  String toString() {
    if (imag.abs() < 1e-10) return real.toStringAsFixed(4);
    if (real.abs() < 1e-10) return '${imag.toStringAsFixed(4)}i';
    final sign = imag >= 0 ? '+' : '-';
    return '${real.toStringAsFixed(4)}$sign${imag.abs().toStringAsFixed(4)}i';
  }
}

/// Matrix type
class Matrix {
  final List<List<double>> data;
  final int rows;
  final int cols;

  Matrix(this.data)
    : rows = data.length,
      cols = data.isEmpty ? 0 : data[0].length {
    // Validate rectangular matrix
    for (final row in data) {
      if (row.length != cols) {
        throw ArgumentError('Matrix must be rectangular');
      }
    }
  }

  factory Matrix.zeros(int rows, int cols) {
    return Matrix(List.generate(rows, (_) => List.filled(cols, 0.0)));
  }

  factory Matrix.identity(int n) {
    final m = Matrix.zeros(n, n);
    for (int i = 0; i < n; i++) {
      m.data[i][i] = 1.0;
    }
    return m;
  }

  double get(int row, int col) => data[row][col];
  void set(int row, int col, double value) => data[row][col] = value;

  Matrix operator +(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw ArgumentError('Matrix dimensions must match');
    }
    final result = Matrix.zeros(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result.data[i][j] = data[i][j] + other.data[i][j];
      }
    }
    return result;
  }

  Matrix operator -(Matrix other) {
    if (rows != other.rows || cols != other.cols) {
      throw ArgumentError('Matrix dimensions must match');
    }
    final result = Matrix.zeros(rows, cols);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result.data[i][j] = data[i][j] - other.data[i][j];
      }
    }
    return result;
  }

  Matrix operator *(dynamic other) {
    if (other is double) {
      final result = Matrix.zeros(rows, cols);
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
          result.data[i][j] = data[i][j] * other;
        }
      }
      return result;
    } else if (other is Matrix) {
      if (cols != other.rows) {
        throw ArgumentError('Invalid matrix dimensions for multiplication');
      }
      final result = Matrix.zeros(rows, other.cols);
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < other.cols; j++) {
          double sum = 0;
          for (int k = 0; k < cols; k++) {
            sum += data[i][k] * other.data[k][j];
          }
          result.data[i][j] = sum;
        }
      }
      return result;
    }
    throw ArgumentError('Invalid multiplication operand');
  }

  Matrix transpose() {
    final result = Matrix.zeros(cols, rows);
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        result.data[j][i] = data[i][j];
      }
    }
    return result;
  }

  double? determinant() {
    if (rows != cols) return null;

    if (rows == 1) return data[0][0];
    if (rows == 2) {
      return data[0][0] * data[1][1] - data[0][1] * data[1][0];
    }

    // Gaussian elimination for larger matrices
    final m = Matrix(data.map((row) => List<double>.from(row)).toList());
    double det = 1.0;

    for (int i = 0; i < rows; i++) {
      // Find pivot
      int pivot = i;
      for (int j = i + 1; j < rows; j++) {
        if (m.data[j][i].abs() > m.data[pivot][i].abs()) {
          pivot = j;
        }
      }

      if (m.data[pivot][i].abs() < 1e-10) return 0.0;

      if (pivot != i) {
        final temp = m.data[i];
        m.data[i] = m.data[pivot];
        m.data[pivot] = temp;
        det *= -1;
      }

      det *= m.data[i][i];

      for (int j = i + 1; j < rows; j++) {
        final factor = m.data[j][i] / m.data[i][i];
        for (int k = i; k < cols; k++) {
          m.data[j][k] -= factor * m.data[i][k];
        }
      }
    }

    return det;
  }

  @override
  String toString() {
    return data.map((row) => '[${row.join(', ')}]').join('\n');
  }
}

// ===================== EVALUATION RESULTS =====================

sealed class EvaluationResult {
  const EvaluationResult();
}

class EvalError extends EvaluationResult {
  final EvalErrorType type;
  final String message;
  const EvalError(this.type, this.message);

  @override
  String toString() => 'Error: $message';
}

enum EvalErrorType { syntax, divisionByZero, domain, dimension, unknown }

class EvalSuccess extends EvaluationResult {
  final double value;
  final Fraction? fraction;
  final Complex? complex;
  final Matrix? matrix;

  const EvalSuccess(this.value, {this.fraction, this.complex, this.matrix});

  @override
  String toString() {
    if (matrix != null) return matrix.toString();
    if (complex != null) return complex.toString();
    if (fraction != null) return fraction.toString();
    return value.toString();
  }
}

// ===================== UTILITIES =====================

class RecursionGuard {
  final int depth;
  final int maxDepth;

  const RecursionGuard(this.depth, this.maxDepth);

  RecursionGuard next() {
    if (depth >= maxDepth) {
      throw const EvalError(
        EvalErrorType.domain,
        'Maximum recursion depth exceeded',
      );
    }
    return RecursionGuard(depth + 1, maxDepth);
  }
}

class FunctionDef {
  final List<String> params;
  final String body;

  const FunctionDef(this.params, this.body);
}

// ===================== NUMBER FORMATTING =====================

class NumberFormatter {
  static String format(
    double value, {
    DisplayMode mode = DisplayMode.normal,
    int precision = 10,
  }) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';

    switch (mode) {
      case DisplayMode.engineering:
        return _formatEngineering(value, precision);
      case DisplayMode.scientific:
        return value.toStringAsExponential(precision);
      case DisplayMode.normal:
        if (value.abs() >= 1e10 || (value.abs() < 1e-3 && value != 0)) {
          return value.toStringAsExponential(precision);
        }
        return value
            .toStringAsFixed(precision)
            .replaceFirst(RegExp(r'\.?0+$'), '');
    }
  }

  static String _formatEngineering(double value, int precision) {
    if (value == 0) return '0';

    final sign = value < 0 ? '-' : '';
    value = value.abs();

    final exp = (math.log(value) / math.ln10).floor();
    final engExp = (exp ~/ 3) * 3;
    final mantissa = value / math.pow(10, engExp);

    final mantissaStr = mantissa
        .toStringAsFixed(precision)
        .replaceFirst(RegExp(r'\.?0+$'), '');

    if (engExp == 0) return '$sign$mantissaStr';
    return '${sign}${mantissaStr}E$engExp';
  }

  static String formatBaseN(int value, BaseMode base) {
    switch (base) {
      case BaseMode.binary:
        return '0b${value.toRadixString(2)}';
      case BaseMode.octal:
        return '0o${value.toRadixString(8)}';
      case BaseMode.hexadecimal:
        return '0x${value.toRadixString(16).toUpperCase()}';
      case BaseMode.decimal:
        return value.toString();
    }
  }
}
