import 'package:flutter/material.dart';

class MatrixTable extends StatelessWidget {
  final List<List<double>> matrix;
  final dynamic theme;

  const MatrixTable({super.key, required this.matrix, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.success, width: 2),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Table(
            border: TableBorder.all(color: theme.subtle),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: matrix.map((row) {
              return TableRow(
                children: row.map((v) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      v.toStringAsFixed(3),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: theme.foreground,
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
