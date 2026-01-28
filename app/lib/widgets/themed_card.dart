import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;

  const ThemedCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.subtle, width: 1),
      ),
      child: child,
    );
  }
}
