import 'package:app/widgets/themed_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_page.dart';
import '../theme/theme_provider.dart';
import '../state/modulo_calculator_state.dart';

class ModuloCalculatorPage extends StatefulWidget {
  const ModuloCalculatorPage({super.key});

  @override
  State<ModuloCalculatorPage> createState() => _ModuloCalculatorPageState();
}

class _ModuloCalculatorPageState extends State<ModuloCalculatorPage> {
  static const List<int> modulusOptions = [
    2,
    3,
    5,
    7,
    11,
    13,
    17,
    19,
    23,
    29,
    31,
    37,
    41,
    43,
    47,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final state = context.watch<ModuloCalculatorState>();

    return AppPage(
      title: 'Modular Arithmetic',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Modulus Selector
          ThemedCard(
            child: Row(
              children: [
                Icon(Icons.percent, color: theme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Modulus:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: theme.subtle),
                    ),
                    child: DropdownButton<int>(
                      value: state.modulus,
                      underline: const SizedBox(),
                      isExpanded: true,
                      dropdownColor: theme.panel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.foreground,
                      ),
                      items: modulusOptions.map((mod) {
                        return DropdownMenuItem(
                          value: mod,
                          child: Text(
                            'mod $mod',
                            style: TextStyle(color: theme.foreground),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) state.setModulus(value);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Display
          ThemedCard(
            color: theme.panel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expression display
                if (state.expression.isNotEmpty)
                  Text(
                    state.expression,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.muted,
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.right,
                  ),
                const SizedBox(height: 8),
                // Main display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.subtle),
                  ),
                  child: SelectableText(
                    state.display,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: theme.foreground,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Calculator Buttons
          ThemedCard(
            child: Column(
              children: [
                // First row - Special operations
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        'AC',
                        () => state.clear(),
                        theme.error,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        '⌫',
                        () => state.backspace(),
                        theme.warning,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        'mod',
                        () => state.reduceModulo(),
                        theme.accent,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        '÷',
                        () => state.performOperation(ModuloOperation.divide),
                        theme.primary,
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Second row - 7, 8, 9, ×
                Row(
                  children: [
                    Expanded(child: _buildNumberButton('7', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberButton('8', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberButton('9', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        '×',
                        () => state.performOperation(ModuloOperation.multiply),
                        theme.primary,
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Third row - 4, 5, 6, −
                Row(
                  children: [
                    Expanded(child: _buildNumberButton('4', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberButton('5', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberButton('6', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        '−',
                        () => state.performOperation(ModuloOperation.subtract),
                        theme.primary,
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Fourth row - 1, 2, 3, +
                Row(
                  children: [
                    Expanded(child: _buildNumberButton('1', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberButton('2', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberButton('3', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        '+',
                        () => state.performOperation(ModuloOperation.add),
                        theme.primary,
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Fifth row - ±, 0, ., =
                Row(
                  children: [
                    Expanded(
                      child: _buildButton(
                        '±',
                        () => state.toggleSign(),
                        theme.secondary,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildNumberButton('0', state, theme)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        '^',
                        () => state.performOperation(ModuloOperation.power),
                        theme.accent,
                        theme,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildButton(
                        '=',
                        () => state.equals(),
                        theme.success,
                        theme,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Advanced Operations
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Operations',
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
                    _buildAdvancedButton(
                      'a⁻¹ mod m',
                      Icons.flip,
                      () => state.calculateModularInverse(),
                      theme.secondary,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'GCD',
                      Icons.calculate,
                      () => state.calculateGCD(),
                      theme.accent,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'LCM',
                      Icons.functions,
                      () => state.calculateLCM(),
                      theme.warning,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'Ext GCD',
                      Icons.scatter_plot,
                      () => state.calculateExtendedGCD(),
                      theme.error,
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Error Display
          if (state.error != null)
            ThemedCard(
              color: theme.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.error, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.error,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.error!,
                          style: TextStyle(fontSize: 14, color: theme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Result Display
          if (state.result != null)
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
                        'Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.success,
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
                      border: Border.all(color: theme.success, width: 2),
                    ),
                    child: SelectableText(
                      state.result!,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'monospace',
                        color: theme.foreground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

          // Message Display (for extended GCD, etc.)
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

          const SizedBox(height: 16),

          // Info Card
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: theme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'About Modular Arithmetic',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Modular arithmetic is a system where numbers "wrap around" upon reaching the modulus. '
                  'It\'s fundamental in cryptography, computer science, and number theory. '
                  'Use this calculator to perform operations in modular arithmetic, including '
                  'modular inverse, GCD, LCM, and extended GCD calculations.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    VoidCallback onTap,
    Color color,
    dynamic theme, {
    double fontSize = 20,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.subtle),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(
    String digit,
    ModuloCalculatorState state,
    dynamic theme,
  ) {
    return InkWell(
      onTap: () => state.appendDigit(digit),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.subtle),
        ),
        child: Text(
          digit,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedButton(
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
    dynamic theme,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.subtle),
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
                fontWeight: FontWeight.bold,
                color: theme.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
