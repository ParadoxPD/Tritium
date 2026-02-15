import 'package:app/widgets/matrix_page/matrix_input.dart';
import 'package:app/widgets/matrix_page/scalar_result_card.dart';
import 'package:app/widgets/themed_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_page.dart';
import '../theme/theme_provider.dart';
import '../state/matrix_calculator_state.dart';

class MatrixCalculatorPage extends StatefulWidget {
  const MatrixCalculatorPage({super.key});

  @override
  State<MatrixCalculatorPage> createState() => _MatrixCalculatorPageState();
}

class _MatrixCalculatorPageState extends State<MatrixCalculatorPage> {
  static const List<int> sizes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  MatrixOperation? _selectedOperation;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final state = context.watch<MatrixCalculatorState>();

    return AppPage(
      title: 'Matrix Calculator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Matrix A
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
                        _buildSizeDropdown(
                          state.rowsA,
                          (v) => state.resizeMatrixA(v!, state.colsA),
                          theme,
                        ),
                        const SizedBox(width: 4),
                        Text('×', style: TextStyle(color: theme.muted)),
                        const SizedBox(width: 4),
                        _buildSizeDropdown(
                          state.colsA,
                          (v) => state.resizeMatrixA(state.rowsA, v!),
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMatrixInput(
                  state.matrixA,
                  state.rowsA,
                  state.colsA,
                  (i, j, v) => state.updateA(i, j, v),
                  theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Matrix B
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
                        _buildSizeDropdown(
                          state.rowsB,
                          (v) => state.resizeMatrixB(v!, state.colsB),
                          theme,
                        ),
                        const SizedBox(width: 4),
                        Text('×', style: TextStyle(color: theme.muted)),
                        const SizedBox(width: 4),
                        _buildSizeDropdown(
                          state.colsB,
                          (v) => state.resizeMatrixB(state.rowsB, v!),
                          theme,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMatrixInput(
                  state.matrixB,
                  state.rowsB,
                  state.colsB,
                  (i, j, v) => state.updateB(i, j, v),
                  theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Scalar Input (for scalar multiplication)
          ThemedCard(
            child: Row(
              children: [
                Text(
                  'Scalar:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        hintText: '1.0',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onChanged: (v) {
                        final value = double.tryParse(v) ?? 1.0;
                        state.updateScalar(value);
                      },
                    ),
                  ),
                ),
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
                      MatrixOperation.add,
                      Icons.add,
                      theme.success,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'A - B',
                      MatrixOperation.subtract,
                      Icons.remove,
                      theme.warning,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'A × B',
                      MatrixOperation.multiply,
                      Icons.close,
                      theme.primary,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'Scalar × A',
                      MatrixOperation.scalarMultiply,
                      Icons.looks_one,
                      theme.accent,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'det(A)',
                      MatrixOperation.determinant,
                      Icons.calculate,
                      theme.secondary,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'A⁻¹',
                      MatrixOperation.inverse,
                      Icons.flip,
                      theme.primary,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'Aᵀ',
                      MatrixOperation.transpose,
                      Icons.swap_calls,
                      theme.secondary,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'rank(A)',
                      MatrixOperation.rank,
                      Icons.stairs,
                      theme.accent,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'trace(A)',
                      MatrixOperation.trace,
                      Icons.trending_up,
                      theme.warning,
                      theme,
                      state,
                    ),
                    _buildOpButton(
                      'eigenvalues(A)',
                      MatrixOperation.eigen,
                      Icons.analytics,
                      theme.error,
                      theme,
                      state,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Result
          if (state.error != null)
            ThemedCard(
              color: theme.error.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: theme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Error',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.error,
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
                      border: Border.all(color: theme.error, width: 2),
                    ),
                    child: SelectableText(
                      state.error!,
                      style: TextStyle(fontSize: 16, color: theme.foreground),
                    ),
                  ),
                ],
              ),
            ),

          if (state.matrixResult != null)
            ThemedCard(
              color: theme.success.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: theme.success),
                      const SizedBox(width: 8),
                      Text(
                        'Result Matrix',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MatrixTable(matrix: state.matrixResult!, theme: theme),
                ],
              ),
            ),

          if (state.scalarResult != null)
            ThemedCard(
              color: theme.success.withValues(alpha: 0.1),
              child: ScalarResultCard(
                label: _getScalarLabel(_selectedOperation),
                value: state.scalarResult!,
                theme: theme,
              ),
            ),

          if (state.message != null)
            ThemedCard(
              color: theme.accent.withValues(alpha: 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.accent,
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
                      border: Border.all(color: theme.accent, width: 2),
                    ),
                    child: SelectableText(
                      state.message!,
                      style: TextStyle(
                        fontSize: 16,
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

  String _getScalarLabel(MatrixOperation? op) {
    return switch (op) {
      MatrixOperation.determinant => 'Determinant',
      MatrixOperation.rank => 'Rank',
      MatrixOperation.trace => 'Trace',
      _ => 'Result',
    };
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
    void Function(int, int, double) onUpdate,
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
                        onUpdate(i, j, value);
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
    MatrixOperation op,
    IconData icon,
    Color color,
    dynamic theme,
    MatrixCalculatorState state,
  ) {
    final isSelected =
        _selectedOperation == op &&
        (state.matrixResult != null ||
            state.scalarResult != null ||
            state.message != null);

    return InkWell(
      onTap: () {
        _unfocusInputs();
        setState(() {
          _selectedOperation = op;
        });
        state.calculate(op);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : theme.panel,
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
