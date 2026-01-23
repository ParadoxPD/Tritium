import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_page.dart';
import '../utils/matrix_operations.dart';
import '../theme/theme_provider.dart';

class MatrixCalculatorPage extends StatefulWidget {
  const MatrixCalculatorPage({Key? key}) : super(key: key);

  @override
  State<MatrixCalculatorPage> createState() => _MatrixCalculatorPageState();
}

class _MatrixCalculatorPageState extends State<MatrixCalculatorPage> {
  static List<int> sizes = [2, 3, 4, 5, 6, 7, 8, 9, 10];
  static int defaultSize = 3;
  int rows1 = defaultSize, cols1 = defaultSize;
  int rows2 = defaultSize, cols2 = defaultSize;
  List<List<double>> matrix1 = [
    [0, 0],
    [0, 0],
  ];
  List<List<double>> matrix2 = [
    [0, 0],
    [0, 0],
  ];
  String result = '';
  String _operation = '';

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
    _unfocusInputs();
    setState(() {
      _operation = operation;
    });

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
        result = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return AppPage(
      title: 'Matrix Calculator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Matrix 1
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Matrix A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Text('Size:', style: TextStyle(color: theme.muted)),
                        const SizedBox(width: 8),
                        _buildSizeDropdown(rows1, (v) {
                          setState(() {
                            rows1 = v!;
                            _resizeMatrix1();
                          });
                        }, theme),
                        const SizedBox(width: 4),
                        Text('×', style: TextStyle(color: theme.muted)),
                        const SizedBox(width: 4),
                        _buildSizeDropdown(cols1, (v) {
                          setState(() {
                            cols1 = v!;
                            _resizeMatrix1();
                          });
                        }, theme),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMatrixInput(matrix1, rows1, cols1, theme),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Matrix 2
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Matrix B',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.secondary,
                      ),
                    ),
                    Row(
                      children: [
                        Text('Size:', style: TextStyle(color: theme.muted)),
                        const SizedBox(width: 8),
                        _buildSizeDropdown(rows2, (v) {
                          setState(() {
                            rows2 = v!;
                            _resizeMatrix2();
                          });
                        }, theme),
                        const SizedBox(width: 4),
                        Text('×', style: TextStyle(color: theme.muted)),
                        const SizedBox(width: 4),
                        _buildSizeDropdown(cols2, (v) {
                          setState(() {
                            cols2 = v!;
                            _resizeMatrix2();
                          });
                        }, theme),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMatrixInput(matrix2, rows2, cols2, theme),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Operations
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildOpButton(
                      'A + B',
                      'add',
                      Icons.add,
                      theme.success,
                      theme,
                    ),
                    _buildOpButton(
                      'A × B',
                      'multiply',
                      Icons.close,
                      theme.primary,
                      theme,
                    ),
                    _buildOpButton(
                      'det(A)',
                      'det',
                      Icons.calculate,
                      theme.accent,
                      theme,
                    ),
                    _buildOpButton(
                      'A^T',
                      'transpose',
                      Icons.swap_calls,
                      theme.secondary,
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Result
          if (result.isNotEmpty)
            ThemedCard(
              color: result.startsWith('Error')
                  ? theme.error.withOpacity(0.1)
                  : theme.success.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        result.startsWith('Error')
                            ? Icons.error_outline
                            : Icons.check_circle,
                        color: result.startsWith('Error')
                            ? theme.error
                            : theme.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        result.startsWith('Error') ? 'Error' : 'Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: result.startsWith('Error')
                              ? theme.error
                              : theme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: result.startsWith('Error')
                            ? theme.error
                            : theme.success,
                        width: 2,
                      ),
                    ),
                    child: SelectableText(
                      result,
                      style: TextStyle(
                        fontSize: result.contains('[') ? 16 : 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: theme.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSizeDropdown(
    int value,
    Function(int?) onChanged,
    dynamic theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.subtle),
      ),
      child: DropdownButton<int>(
        value: value,
        underline: const SizedBox(),
        dropdownColor: theme.panel,
        style: TextStyle(fontSize: 14, color: theme.foreground),
        items: sizes.map((i) {
          return DropdownMenuItem(
            value: i,
            child: Text('$i', style: TextStyle(color: theme.foreground)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMatrixInput(
    List<List<double>> matrix,
    int rows,
    int cols,
    dynamic theme,
  ) {
    return Column(
      children: List.generate(
        rows,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(
              cols,
              (j) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.subtle),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.foreground,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hintText: '0',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onChanged: (v) {
                        final value = double.tryParse(v) ?? 0;
                        setState(() {
                          matrix[i][j] = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOpButton(
    String label,
    String op,
    IconData icon,
    Color color,
    dynamic theme,
  ) {
    final isSelected = _operation == op && result.isNotEmpty;

    return InkWell(
      onTap: () => _calculate(op),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : theme.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : theme.subtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: theme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _unfocusInputs() {
    FocusScope.of(context).unfocus();
  }
}
