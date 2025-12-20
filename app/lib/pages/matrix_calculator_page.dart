import 'package:flutter/material.dart';
import '../widgets/matrix_input.dart';
import '../utils/matrix_operations.dart';

class MatrixCalculatorPage extends StatefulWidget {
  const MatrixCalculatorPage({Key? key}) : super(key: key);

  @override
  State<MatrixCalculatorPage> createState() => _MatrixCalculatorPageState();
}

class _MatrixCalculatorPageState extends State<MatrixCalculatorPage> {
  int rows1 = 2, cols1 = 2;
  int rows2 = 2, cols2 = 2;
  List<List<double>> matrix1 = [
    [0, 0],
    [0, 0],
  ];
  List<List<double>> matrix2 = [
    [0, 0],
    [0, 0],
  ];
  String result = '';

  void _resizeMatrix1() {
    setState(() {
      matrix1 = List.generate(rows1, (i) => List.filled(cols1, 0.0));
    });
  }

  void _resizeMatrix2() {
    setState(() {
      matrix2 = List.generate(rows2, (i) => List.filled(cols2, 0.0));
    });
  }

  void _calculate(String operation) {
    try {
      switch (operation) {
        case 'add':
          final resultMatrix = MatrixOperations.add(matrix1, matrix2);
          setState(() {
            result = MatrixOperations.formatMatrix(resultMatrix);
          });
          break;
        case 'multiply':
          final resultMatrix = MatrixOperations.multiply(matrix1, matrix2);
          setState(() {
            result = MatrixOperations.formatMatrix(resultMatrix);
          });
          break;
        case 'det':
          final det = MatrixOperations.determinant(matrix1);
          setState(() {
            result = 'Determinant: ${det.toStringAsFixed(4)}';
          });
          break;
        case 'transpose':
          final resultMatrix = MatrixOperations.transpose(matrix1);
          setState(() {
            result = MatrixOperations.formatMatrix(resultMatrix);
          });
          break;
      }
    } catch (e) {
      setState(() {
        result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Matrix 1 size: '),
              DropdownButton<int>(
                value: rows1,
                items: [2, 3, 4]
                    .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    rows1 = v!;
                    _resizeMatrix1();
                  });
                },
              ),
              const Text(' × '),
              DropdownButton<int>(
                value: cols1,
                items: [2, 3, 4]
                    .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    cols1 = v!;
                    _resizeMatrix1();
                  });
                },
              ),
            ],
          ),
          MatrixInput(
            matrix: matrix1,
            rows: rows1,
            cols: cols1,
            onChanged: (i, j, value) {
              setState(() {
                matrix1[i][j] = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Matrix 2 size: '),
              DropdownButton<int>(
                value: rows2,
                items: [2, 3, 4]
                    .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    rows2 = v!;
                    _resizeMatrix2();
                  });
                },
              ),
              const Text(' × '),
              DropdownButton<int>(
                value: cols2,
                items: [2, 3, 4]
                    .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    cols2 = v!;
                    _resizeMatrix2();
                  });
                },
              ),
            ],
          ),
          MatrixInput(
            matrix: matrix2,
            rows: rows2,
            cols: cols2,
            onChanged: (i, j, value) {
              setState(() {
                matrix2[i][j] = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _calculate('add'),
                child: const Text('Add'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('multiply'),
                child: const Text('Multiply'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('det'),
                child: const Text('Det(M1)'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('transpose'),
                child: const Text('Transpose M1'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(result.isEmpty ? 'Result will appear here' : result),
            ),
          ),
        ],
      ),
    );
  }
}
