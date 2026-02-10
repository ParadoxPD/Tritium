// Update MatrixMathModule
import 'dart:math' as math;
import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/engine/library/library_module.dart';
import 'package:app/core/eval_types.dart';
import 'package:app/core/engine/evaluator/runtime_errors.dart';

class MatrixMathModule extends LibraryModule {
  @override
  Map<String, Value> get constants => {};

  @override
  Map<String, NativeFunction> get functions => {
    'inv': NativeFunction(1, (args, context) => _toMatrixOp(args, _inverse)),
    'rank': NativeFunction(1, (args, context) => _toMatrixOp(args, _rank)),
    'trace': NativeFunction(1, (args, context) => _toMatrixOp(args, _trace)),
    'det': NativeFunction(
      1,
      (args, context) => _toMatrixOp(args, _determinant),
    ),
    'eigenvalues': NativeFunction(
      1,
      (args, context) => _toMatrixOp(args, _eigenvalues),
    ),
    'transpose': NativeFunction(
      1,
      (args, context) => _toMatrixOp(args, _transpose),
    ),
  };

  Value _toMatrixOp(List<Value> args, Value Function(MatrixValue) op) {
    if (args[0] is! MatrixValue) {
      throw RuntimeError(
        message: 'Function expects a matrix, got ${args[0].runtimeType}',
      );
    }
    return op(args[0] as MatrixValue);
  }

  Value _trace(MatrixValue m) {
    if (m.rows != m.cols) {
      throw RuntimeError(message: 'Trace requires a square matrix');
    }
    double sum = 0;
    for (int i = 0; i < m.rows; i++) {
      sum += m.data[i][i];
    }
    return NumberValue(sum);
  }

  Value _transpose(MatrixValue m) {
    final result = List.generate(
      m.cols,
      (j) => List.generate(m.rows, (i) => m.data[i][j]),
    );
    return MatrixValue(result);
  }

  Value _rank(MatrixValue m) {
    List<List<double>> temp = m.data.map((r) => List<double>.from(r)).toList();
    int rank = 0;
    int R = m.rows;
    int C = m.cols;

    for (int row = 0; row < R && rank < C; row++) {
      if (temp[row][rank] != 0) {
        for (int i = 0; i < R; i++) {
          if (i != row) {
            double factor = temp[i][rank] / temp[row][rank];
            for (int j = rank; j < C; j++) {
              temp[i][j] -= factor * temp[row][j];
            }
          }
        }
      } else {
        int reduce = 1;
        while (row + reduce < R && temp[row + reduce][rank] == 0) {
          reduce++;
        }
        if (row + reduce == R) {
          rank--;
        } else {
          var swap = temp[row];
          temp[row] = temp[row + reduce];
          temp[row + reduce] = swap;
          row--;
        }
      }
      rank++;
    }
    return NumberValue(rank.toDouble());
  }

  Value _inverse(MatrixValue m) {
    if (m.rows != m.cols) {
      throw RuntimeError(message: 'Matrix must be square for inverse');
    }
    int n = m.rows;
    List<List<double>> aug = List.generate(n, (i) {
      return [...m.data[i], ...List.generate(n, (j) => i == j ? 1.0 : 0.0)];
    });

    for (int i = 0; i < n; i++) {
      double pivot = aug[i][i];
      if (pivot.abs() < 1e-10) {
        throw RuntimeError(message: 'Matrix is singular and cannot be inverted');
      }
      for (int j = 0; j < 2 * n; j++) {
        aug[i][j] /= pivot;
      }
      for (int k = 0; k < n; k++) {
        if (k != i) {
          double factor = aug[k][i];
          for (int j = 0; j < 2 * n; j++) {
            aug[k][j] -= factor * aug[i][j];
          }
        }
      }
    }
    return MatrixValue(aug.map((row) => row.sublist(n)).toList());
  }

  Value _eigenvalues(MatrixValue m) {
    if (m.rows != m.cols) {
      throw RuntimeError(message: 'Eigenvalues require a square matrix');
    }

    MatrixValue currentA = m;
    for (int i = 0; i < 100; i++) {
      final qr = _qrDecomposition(currentA);
      final Q = qr['Q']!;
      final R = qr['R']!;
      currentA = _multiply(R, Q);
    }

    final evals = List.generate(
      currentA.rows,
      (i) => NumberValue(currentA.data[i][i]),
    );
    return ListValue(evals);
  }

  Map<String, MatrixValue> _qrDecomposition(MatrixValue A) {
    int m = A.rows;
    int n = A.cols;
    List<List<double>> Q = List.generate(m, (_) => List.filled(n, 0.0));
    List<List<double>> R = List.generate(n, (_) => List.filled(n, 0.0));
    List<List<double>> columns = List.generate(
      n,
      (j) => List.generate(m, (i) => A.data[i][j]),
    );

    for (int j = 0; j < n; j++) {
      List<double> v = List.from(columns[j]);
      for (int i = 0; i < j; i++) {
        R[i][j] = _dotProduct(List.generate(m, (k) => Q[k][i]), columns[j]);
        for (int k = 0; k < m; k++) {
          v[k] -= R[i][j] * Q[k][i];
        }
      }
      R[j][j] = _norm(v);
      for (int k = 0; k < m; k++) {
        Q[k][j] = (R[j][j] == 0) ? 0 : v[k] / R[j][j];
      }
    }

    return {'Q': MatrixValue(Q), 'R': MatrixValue(R)};
  }

  double _dotProduct(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }

  double _norm(List<double> v) => math.sqrt(_dotProduct(v, v));

  MatrixValue _multiply(MatrixValue a, MatrixValue b) {
    final result = List.generate(
      a.rows,
      (i) => List.generate(b.cols, (j) {
        double sum = 0;
        for (int k = 0; k < a.cols; k++) {
          sum += a.data[i][k] * b.data[k][j];
        }
        return sum;
      }),
    );
    return MatrixValue(result);
  }

  Value _determinant(MatrixValue m) {
    if (m.rows != m.cols) {
      throw RuntimeError(message: 'Determinant requires square matrix');
    }
    return NumberValue(_det(m.data));
  }

  double _det(List<List<double>> matrix) {
    int n = matrix.length;
    if (n == 1) return matrix[0][0];
    if (n == 2) {
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    }

    double determinant = 0;
    for (int col = 0; col < n; col++) {
      determinant += matrix[0][col] * _cofactor(matrix, 0, col);
    }
    return determinant;
  }

  double _cofactor(List<List<double>> matrix, int row, int col) {
    return math.pow(-1, row + col).toDouble() * _det(_minor(matrix, row, col));
  }

  List<List<double>> _minor(List<List<double>> matrix, int row, int col) {
    return [
      for (int i = 0; i < matrix.length; i++)
        if (i != row)
          [
            for (int j = 0; j < matrix.length; j++)
              if (j != col) matrix[i][j],
          ],
    ];
  }
}
