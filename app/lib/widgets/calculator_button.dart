import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

enum ButtonType { number, operator, function, special, equals, clear }

class CalculatorButton extends StatelessWidget {
  final String text;
  final ButtonType type;
  final Function(String) onPressed;
  final bool isWide;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    Color getColor() {
      switch (type) {
        case ButtonType.number:
          return theme.buttonNumber;
        case ButtonType.operator:
          return theme.buttonOperator;
        case ButtonType.function:
          return theme.buttonFunction;
        case ButtonType.special:
          return theme.buttonSpecial;
        case ButtonType.equals:
          return theme.buttonEquals;
        case ButtonType.clear:
          return theme.buttonClear;
      }
    }

    return Material(
      color: getColor(),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => onPressed(text),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.subtle.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
                color: theme.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSize() {
    if (text.length > 6) return 12;
    if (text.length > 3) return 14;
    return 18;
  }
}
