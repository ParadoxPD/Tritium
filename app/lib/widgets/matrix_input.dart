import 'package:flutter/material.dart';

class MatrixInput extends StatelessWidget {
  final List<List<double>> matrix;
  final int rows;
  final int cols;
  final Function(int, int, double) onChanged;

  const MatrixInput({
    Key? key,
    required this.matrix,
    required this.rows,
    required this.cols,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rows,
        (i) => Row(
          children: List.generate(
            cols,
            (j) => Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(8),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final value = double.tryParse(v) ?? 0;
                    onChanged(i, j, value);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
