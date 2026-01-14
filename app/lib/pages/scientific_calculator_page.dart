import 'package:app/core/evaluator/eval_types.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/calculator_state.dart';
import '../widgets/calculator_button.dart';
import '../theme/theme_provider.dart';

class ScientificCalculatorPage extends StatelessWidget {
  const ScientificCalculatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorState>();
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Column(
      children: [
        // DISPLAY
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.displayBackground,
            border: Border(bottom: BorderSide(color: theme.subtle, width: 2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Mode indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.success, width: 1),
                    ),
                    child: Text(
                      state.angleMode == AngleMode.rad ? 'RAD' : 'DEG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.success,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: theme.muted),
                    onPressed: () => _showSettings(context),
                    iconSize: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Expression with cursor
              GestureDetector(
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final dx = details.localPosition.dx;
                  final charWidth = 14.0;
                  final index = (dx / charWidth).floor();
                  state.setCursor(index);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      children: [
                        for (int i = 0; i <= state.expression.length; i++)
                          TextSpan(
                            text: i == state.cursor
                                ? '|'
                                : (i < state.expression.length
                                      ? state.expression[i]
                                      : ''),
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'monospace',
                              color: i == state.cursor
                                  ? theme.primary
                                  : theme.muted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Result display
              Text(
                state.display,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: theme.displayText,
                ),
              ),
            ],
          ),
        ),

        // BUTTONS
        Expanded(
          child: Container(
            color: theme.background,
            child: GridView.count(
              crossAxisCount: 5,
              padding: const EdgeInsets.all(8),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: _buttons(context),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buttons(BuildContext context) {
    void press(String v) => context.read<CalculatorState>().input(v);

    Widget btn(String t, ButtonType type) =>
        CalculatorButton(text: t, type: type, onPressed: press);

    return [
      btn('sin(', ButtonType.function),
      btn('cos(', ButtonType.function),
      btn('tan(', ButtonType.function),
      btn('ln(', ButtonType.function),
      btn('log(', ButtonType.function),

      btn('sqrt(', ButtonType.function),
      btn('^', ButtonType.operator),
      btn('π', ButtonType.special),
      btn('e', ButtonType.special),
      btn('RAD/DEG', ButtonType.special),

      btn('7', ButtonType.number),
      btn('8', ButtonType.number),
      btn('9', ButtonType.number),
      btn('C', ButtonType.clear),
      btn('DEL', ButtonType.clear),

      btn('4', ButtonType.number),
      btn('5', ButtonType.number),
      btn('6', ButtonType.number),
      btn('*', ButtonType.operator),
      btn('/', ButtonType.operator),

      btn('1', ButtonType.number),
      btn('2', ButtonType.number),
      btn('3', ButtonType.number),
      btn('+', ButtonType.operator),
      btn('-', ButtonType.operator),

      btn('0', ButtonType.number),
      btn('.', ButtonType.number),
      btn('=', ButtonType.equals),
      btn('(', ButtonType.special),
      btn(')', ButtonType.special),

      btn('ANS', ButtonType.special),
      btn('MC', ButtonType.special),
      btn('MR', ButtonType.special),
      btn('M+', ButtonType.special),
      btn('M-', ButtonType.special),
    ];
  }

  void _showSettings(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final themeProvider = context.watch<ThemeProvider>();
        final current = themeProvider.currentTheme;

        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: current.surface,
              title: Text(
                'Appearance',
                style: TextStyle(color: current.foreground),
              ),
              content: SizedBox(
                width: 300, // Fixed width prevents layout jumping
                height: 400, // Fixed height makes it scrollable
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ThemeType.values.length,
                  itemBuilder: (context, index) {
                    final type = ThemeType.values[index];
                    final isSelected = themeProvider.themeType == type;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? current.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? current.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: ListTile(
                        onTap: () => themeProvider.setTheme(type),
                        leading: _buildColorPreview(type), // Tiny color dots
                        title: Text(
                          type.name
                              .replaceAllMapped(
                                RegExp(r'([A-Z])'),
                                (m) => ' ${m.group(0)}',
                              )
                              .trim(),
                          style: TextStyle(
                            color: isSelected
                                ? current.primary
                                : current.foreground,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: current.primary,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Close',
                    style: TextStyle(color: current.primary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to show 3 dots of the theme's colors in the list
  Widget _buildColorPreview(ThemeType type) {
    // This is a bit of a hack to get colors without switching the whole app theme
    // You might want to move this logic to your ThemeProvider
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
