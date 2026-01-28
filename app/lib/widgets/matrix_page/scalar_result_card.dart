import 'package:flutter/material.dart';

class ScalarResultCard extends StatelessWidget {
  final String label;
  final double value;
  final dynamic theme;

  const ScalarResultCard({
    super.key,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.success, width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: theme.muted)),
          const SizedBox(height: 8),
          SelectableText(
            value.toStringAsFixed(6),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: theme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
