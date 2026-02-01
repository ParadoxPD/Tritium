// ============================================================================
// FILE: core/eval_types.dart
// Core type definitions that won't change
// ============================================================================

import 'package:app/core/engine/binder/symbol_table.dart';

/// Represents all possible value types in the calculator
sealed class Value {
  const Value();

  /// Convert to display string
  String toDisplayString();

  /// Convert to double if possible (for compatibility)
  double? toDouble();

  ValueType type();
}

class NumberValue extends Value {
  final double value;
  const NumberValue(this.value);

  static const double _maxExactInt = 9e15;

  @override
  String toDisplayString() {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value.isNegative ? '-∞' : '∞';

    final abs = value.abs();
    if (abs >= 1e12 || (abs > 0 && abs < 1e-6)) {
      return value.toStringAsExponential(6);
    }

    if (value % 1 == 0 && abs < _maxExactInt) {
      return value.toInt().toString();
    }

    // Normal decimal
    return value.toStringAsPrecision(12).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  double toDouble() => value;

  @override
  ValueType type() => ValueType.number;
}

class ComplexValue extends Value {
  final double real;
  final double imaginary;
  const ComplexValue(this.real, this.imaginary);

  @override
  String toDisplayString() {
    if (imaginary.abs() < 1e-10) return real.toStringAsFixed(4);
    if (real.abs() < 1e-10) return '${imaginary.toStringAsFixed(4)}i';
    final sign = imaginary >= 0 ? '+' : '-';
    return '${real.toStringAsFixed(4)}$sign${imaginary.abs().toStringAsFixed(4)}i';
  }

  @override
  double? toDouble() => imaginary.abs() < 1e-10 ? real : null;

  @override
  ValueType type() {
    return ValueType.complex;
  }
}

class MatrixValue extends Value {
  final List<List<double>> data;
  final int rows;
  final int cols;

  MatrixValue(this.data)
    : rows = data.length,
      cols = data.isEmpty ? 0 : data[0].length;

  @override
  String toDisplayString() {
    return data.map((row) => '[${row.join(', ')}]').join('\n');
  }

  @override
  double? toDouble() => rows == 1 && cols == 1 ? data[0][0] : null;

  @override
  ValueType type() {
    return ValueType.matrix;
  }
}

class VectorValue extends Value {
  final List<double> components;
  const VectorValue(this.components);

  int get dimension => components.length;

  @override
  String toDisplayString() {
    return '(${components.map((c) => c.toStringAsFixed(4)).join(', ')})';
  }

  @override
  double? toDouble() => null;

  @override
  ValueType type() {
    return ValueType.vector;
  }
}

class FractionValue extends Value {
  final int numerator;
  final int denominator;
  const FractionValue(this.numerator, this.denominator);

  @override
  String toDisplayString() {
    if (denominator == 1) return '$numerator';
    return '$numerator/$denominator';
  }

  @override
  double toDouble() => numerator / denominator;

  @override
  ValueType type() {
    return ValueType.fraction;
  }
}

class BooleanValue extends Value {
  final bool value;
  const BooleanValue(this.value);

  @override
  String toDisplayString() => value ? 'true' : 'false';

  @override
  double? toDouble() => null;

  @override
  ValueType type() {
    return ValueType.boolean;
  }
}

class StringValue extends Value {
  final String value;
  const StringValue(this.value);

  @override
  String toDisplayString() => value;

  @override
  double? toDouble() => double.tryParse(value);

  @override
  ValueType type() {
    return ValueType.string;
  }
}

// For future geometry, finance, etc.
class RecordValue extends Value {
  final Map<String, Value> fields;
  const RecordValue(this.fields);

  @override
  String toDisplayString() {
    return fields.entries
        .map((e) => '${e.key}: ${e.value.toDisplayString()}')
        .join(', ');
  }

  @override
  double? toDouble() => null;

  @override
  ValueType type() {
    return ValueType.record;
  }
}

class ListValue extends Value {
  final List<Value> values;
  const ListValue(this.values);

  @override
  String toDisplayString() {
    return '[${values.map((v) => v.toDisplayString()).join(', ')}]';
  }

  @override
  double? toDouble() => null;

  @override
  ValueType type() {
    return ValueType.list;
  }
}

class NumberValueSci extends Value {
  final double mantissa;
  final int exponent;

  NumberValueSci(this.mantissa, this.exponent);

  @override
  String toDisplayString() =>
      exponent > 0 ? "${mantissa}e+$exponent" : "$mantissa";

  @override
  double? toDouble() => null;

  @override
  ValueType type() {
    return ValueType.number;
  }
}

// ============================================================================
// This architecture supports:
// - All current features (scientific calc, matrices, complex numbers)
// - Easy addition of new value types (geometry shapes, finance records)
// - Type checking in binder phase
// - Clean separation of concerns
// - Incremental feature additions
// ============================================================================
