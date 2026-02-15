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
  final TextEditingController _modulusController = TextEditingController();
  final FocusNode _modulusFocusNode = FocusNode();
  bool _didInitModulus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitModulus) return;
    final state = context.read<ModuloCalculatorState>();
    _modulusController.text = state.modulus.toString();
    _didInitModulus = true;
  }

  @override
  void dispose() {
    _modulusController.dispose();
    _modulusFocusNode.dispose();
    super.dispose();
  }

  Future<void> _showSingleIntDialog(
    BuildContext context, {
    required String title,
    required String label,
    required String initialValue,
    required void Function(int) onConfirm,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final state = context.read<ModuloCalculatorState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null) {
                state.setError('$label must be an integer');
                return;
              }
              Navigator.of(ctx).pop();
              onConfirm(value);
            },
            child: const Text('Run'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTwoIntDialog(
    BuildContext context, {
    required String title,
    required String firstLabel,
    required String secondLabel,
    required String firstInitial,
    required String secondInitial,
    required void Function(int, int) onConfirm,
  }) async {
    final firstController = TextEditingController(text: firstInitial);
    final secondController = TextEditingController(text: secondInitial);
    final state = context.read<ModuloCalculatorState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: firstLabel),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: secondController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: secondLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final a = int.tryParse(firstController.text.trim());
              final b = int.tryParse(secondController.text.trim());
              if (a == null || b == null) {
                state.setError('Both values must be integers');
                return;
              }
              Navigator.of(ctx).pop();
              onConfirm(a, b);
            },
            child: const Text('Run'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMatrixDialog(BuildContext context) async {
    final controller = TextEditingController(text: '[[1,2],[3,5]]');
    final state = context.read<ModuloCalculatorState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Matrix Inverse mod m'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a square integer matrix literal, e.g. [[1,2],[3,5]]',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Matrix'),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final matrixLiteral = controller.text.trim();
              if (matrixLiteral.isEmpty) {
                state.setError('Matrix input cannot be empty');
                return;
              }
              Navigator.of(ctx).pop();
              state.calculateMatrixInverseModulo(matrixLiteral);
            },
            child: const Text('Run'),
          ),
        ],
      ),
    );
  }

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
                  child: TextField(
                    controller: _modulusController,
                    focusNode: _modulusFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixText: 'mod ',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: theme.panel,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: theme.subtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: theme.primary),
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.foreground,
                    ),
                    onChanged: state.updateModulusFromInput,
                    onSubmitted: state.setModulusFromInput,
                    onTapOutside: (_) {
                      _modulusFocusNode.unfocus();
                      state.setModulusFromInput(_modulusController.text);
                    },
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
                        'φ(n)',
                        () => _showSingleIntDialog(
                          context,
                          title: 'Euler Totient',
                          label: 'n',
                          initialValue: state.display,
                          onConfirm: state.calculateEulerTotientFor,
                        ),
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
                      () => _showSingleIntDialog(
                        context,
                        title: 'Modular Inverse',
                        label: 'a',
                        initialValue: state.display,
                        onConfirm: state.calculateModularInverseFor,
                      ),
                      theme.secondary,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'a^b mod m',
                      Icons.exposure,
                      () => _showTwoIntDialog(
                        context,
                        title: 'Modular Power',
                        firstLabel: 'base (a)',
                        secondLabel: 'exponent (b)',
                        firstInitial: state.display,
                        secondInitial: '2',
                        onConfirm: state.calculateModPowerFor,
                      ),
                      theme.primary,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'GCD',
                      Icons.calculate,
                      () => _showTwoIntDialog(
                        context,
                        title: 'Greatest Common Divisor',
                        firstLabel: 'a',
                        secondLabel: 'b',
                        firstInitial: state.display,
                        secondInitial: '0',
                        onConfirm: state.calculateGCDFor,
                      ),
                      theme.accent,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'LCM',
                      Icons.functions,
                      () => _showTwoIntDialog(
                        context,
                        title: 'Least Common Multiple',
                        firstLabel: 'a',
                        secondLabel: 'b',
                        firstInitial: state.display,
                        secondInitial: '0',
                        onConfirm: state.calculateLCMFor,
                      ),
                      theme.warning,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'Ext GCD',
                      Icons.scatter_plot,
                      () => _showTwoIntDialog(
                        context,
                        title: 'Extended GCD',
                        firstLabel: 'a',
                        secondLabel: 'b',
                        firstInitial: state.display,
                        secondInitial: '0',
                        onConfirm: state.calculateExtendedGCDFor,
                      ),
                      theme.error,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'Congruence',
                      Icons.rule,
                      () => _showTwoIntDialog(
                        context,
                        title: 'Check Congruence',
                        firstLabel: 'a',
                        secondLabel: 'b',
                        firstInitial: state.display,
                        secondInitial: '0',
                        onConfirm: state.checkCongruenceFor,
                      ),
                      theme.secondary,
                      theme,
                    ),
                    _buildAdvancedButton(
                      'Matrix Inv',
                      Icons.grid_on,
                      () => _showMatrixDialog(context),
                      theme.primary,
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
