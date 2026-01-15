import 'package:app/core/evaluator/eval_types.dart';
import 'package:app/theme/theme_data.dart';
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
    // Local state for the toggle filter within the dialog
    ThemeMode filterMode = ThemeMode.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final provider = context.watch<ThemeProvider>();
            final current = provider.currentTheme;

            // Filter the list based on the toggle
            final filteredThemes = filterMode == ThemeMode.dark
                ? provider.darkThemes
                : provider.lightThemes;

            return AlertDialog(
              backgroundColor: current.surface,
              title: Text(
                'Appearance',
                style: TextStyle(color: current.foreground),
              ),
              contentPadding: const EdgeInsets.only(top: 20),
              content: SizedBox(
                width: double.maxFinite,
                height: 450,
                child: Column(
                  children: [
                    // --- DARK/LIGHT FILTER TOGGLE ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                        ],
                        selected: {filterMode},
                        onSelectionChanged: (Set<ThemeMode> selection) {
                          setDialogState(() => filterMode = selection.first);
                        },
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: current.primary,
                          selectedForegroundColor: current.background,
                          side: BorderSide(color: current.subtle),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: current.subtle, height: 1),

                    // --- THEME LIST ---
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredThemes.length,
                        itemBuilder: (context, index) {
                          final type = filteredThemes[index];
                          final themeData = ThemeProvider.getThemeData(type);
                          final isSelected = provider.themeType == type;

                          return ListTile(
                            onTap: () => provider.setTheme(type),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            leading: _buildThemeSwatches(themeData),
                            title: Text(
                              type.name
                                  .replaceAllMapped(
                                    RegExp(r'([A-Z])'),
                                    (m) => ' ${m.group(0)}',
                                  )
                                  .trim(),
                              style: TextStyle(
                                color: isSelected
                                    ? themeData.primary
                                    : current.foreground,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: themeData.primary,
                                    size: 20,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    Divider(color: current.subtle, height: 1),
                  ],
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
            );
          },
        );
      },
    );
  }

  // Builds the 3-dot color preview for the leading section of the ListTile
  Widget _buildThemeSwatches(AppThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(theme.primary),
        const SizedBox(width: 4),
        _dot(theme.success),
        const SizedBox(width: 4),
        _dot(theme.error),
      ],
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
    );
  }
}
