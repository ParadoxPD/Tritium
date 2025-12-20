import 'dart:math' as math;

class MatrixOperations {
  static List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw Exception('Dimension mismatch');
    }

    return List.generate(
      a.length,
      (i) => List.generate(a[0].length, (j) => a[i][j] + b[i][j]),
    );
  }

  static List<List<double>> multiply(
    List<List<double>> a,
    List<List<double>> b,
  ) {
    if (a[0].length != b.length) {
      throw Exception('Cannot multiply: incompatible dimensions');
    }

    return List.generate(
      a.length,
      (i) => List.generate(b[0].length, (j) {
        double sum = 0;
        for (int k = 0; k < a[0].length; k++) {
          sum += a[i][k] * b[k][j];
        }
        return sum;
      }),
    );
  }

  static double determinant(List<List<double>> matrix) {
    final n = matrix.length;
    if (n != matrix[0].length) {
      throw Exception('Matrix must be square');
    }

    if (n == 1) return matrix[0][0];
    if (n == 2) {
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    }

    double det = 0;
    for (int col = 0; col < n; col++) {
      det +=
          math.pow(-1, col) *
          matrix[0][col] *
          determinant(_getMinor(matrix, 0, col));
    }
    return det;
  }

  static List<List<double>> transpose(List<List<double>> matrix) {
    return List.generate(
      matrix[0].length,
      (i) => List.generate(matrix.length, (j) => matrix[j][i]),
    );
  }

  static List<List<double>> _getMinor(
    List<List<double>> matrix,
    int row,
    int col,
  ) {
    return matrix
        .asMap()
        .entries
        .where((e) => e.key != row)
        .map(
          (e) => e.value
              .asMap()
              .entries
              .where((c) => c.key != col)
              .map((c) => c.value)
              .toList(),
        )
        .toList();
  }

  static String formatMatrix(List<List<double>> matrix) {
    return matrix
        .map((row) => '[${row.map((v) => v.toStringAsFixed(2)).join(', ')}]')
        .join('\n');
  }
}
