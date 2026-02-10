import 'package:app/services/logging_service.dart';
import 'package:flutter/material.dart';
import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';

enum MatrixOperation {
  add,
  subtract,
  multiply,
  scalarMultiply,
  determinant,
  inverse,
  transpose,
  eigen,
  rank,
  trace,
}

class MatrixCalculatorState extends ChangeNotifier {
  final EvaluationEngine _engine;
  final EvalContext _context = const EvalContext();
  final LoggerService _logger = LoggerService();

  // Input Data
  int rowsA = 3, colsA = 3;
  int rowsB = 3, colsB = 3;
  List<List<double>> matrixA = [];
  List<List<double>> matrixB = [];
  double scalar = 1.0;

  // Results
  List<List<double>>? matrixResult;
  double? scalarResult;
  String? message;
  String? error;

  MatrixCalculatorState(this._engine) {
    _initMatrices();
  }

  void _initMatrices() {
    matrixA = List.generate(rowsA, (_) => List.filled(colsA, 0.0));
    matrixB = List.generate(rowsB, (_) => List.filled(colsB, 0.0));
  }

  // --- UI Helpers for data entry ---

  void updateA(int i, int j, double v) => matrixA[i][j] = v;
  void updateB(int i, int j, double v) => matrixB[i][j] = v;
  void updateScalar(double v) {
    scalar = v;
    notifyListeners();
  }

  void clearResult() {
    matrixResult = null;
    scalarResult = null;
    message = null;
    error = null;
    notifyListeners();
  }

  // --- The New Engine-Powered Calculation Logic ---

  void calculate(MatrixOperation op) {
    _clearResult();

    // 1. Convert our UI matrices into engine-compatible strings
    final strA = _formatMatrixForEngine(matrixA);
    final strB = _formatMatrixForEngine(matrixB);

    // 2. Build the expression string based on the operation
    final expression = switch (op) {
      MatrixOperation.add => "$strA + $strB",
      MatrixOperation.subtract => "$strA - $strB",
      MatrixOperation.multiply => "$strA * $strB",
      MatrixOperation.scalarMultiply => "$scalar * $strA",
      MatrixOperation.inverse => "inv($strA)",
      MatrixOperation.rank => "rank($strA)",
      MatrixOperation.trace => "trace($strA)",
      MatrixOperation.determinant => "det($strA)",
      MatrixOperation.transpose => "transpose($strA)",
      MatrixOperation.eigen => "eigenvalues($strA)",
    };

    _logger.trace(expression);

    // 3. Evaluate using the engine
    final result = _engine.evaluate(expression, _context);

    // 4. Handle the resulting Value types
    if (result is EngineSuccess) {
      _processEngineValue(result.value);
    } else if (result is EngineError) {
      error = result.toString();
    }

    notifyListeners();
  }

  void _processEngineValue(Value val) {
    if (val is MatrixValue) {
      matrixResult = val.data;
    } else if (val is NumberValue) {
      scalarResult = val.value;
    } else if (val is ListValue) {
      // Used for eigenvalues which returns a list
      message =
          "Eigenvalues: ${val.values.map((e) => e.toDisplayString()).join(', ')}";
    }
  }

  String _formatMatrixForEngine(List<List<double>> data) {
    final rows = data.map((row) => "[${row.join(',')}]").join(',');
    return "[$rows]";
  }

  void _clearResult() {
    matrixResult = null;
    scalarResult = null;
    message = null;
    error = null;
  }

  // ... (resizeMatrixA and resizeMatrixB remain same as your original)

  void resizeMatrixA(int r, int c) {
    rowsA = r;
    colsA = c;
    matrixA = List.generate(r, (_) => List.filled(c, 0.0));
    notifyListeners();
  }

  void resizeMatrixB(int r, int c) {
    rowsB = r;
    colsB = c;
    matrixB = List.generate(r, (_) => List.filled(c, 0.0));
    notifyListeners();
  }
}
