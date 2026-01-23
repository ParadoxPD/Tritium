import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/modulo_operations.dart';
import '../widgets/app_page.dart';
import '../theme/theme_provider.dart';

class ModuloCalculatorPage extends StatefulWidget {
  const ModuloCalculatorPage({Key? key}) : super(key: key);

  @override
  State<ModuloCalculatorPage> createState() => _ModuloCalculatorPageState();
}

class _ModuloCalculatorPageState extends State<ModuloCalculatorPage> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _modController = TextEditingController();
  String _result = '';
  String _operation = '';
  String _error = '';

  void _calculate(String operation) {
    _unfocusInputs();

    setState(() {
      _error = '';
      _result = '';
      _operation = operation;
    });

    try {
      final a = int.parse(_aController.text);
      final b = int.parse(_bController.text);
      final mod = int.parse(_modController.text);

      int result;
      switch (operation) {
        case 'add':
          result = ModuloOperations.add(a, b, mod);
          break;
        case 'sub':
          result = ModuloOperations.subtract(a, b, mod);
          break;
        case 'mul':
          result = ModuloOperations.multiply(a, b, mod);
          break;
        case 'pow':
          result = ModuloOperations.power(a, b, mod);
          break;
        case 'inv':
          result = ModuloOperations.inverse(a, mod);
          break;
        default:
          result = 0;
      }

      setState(() {
        _result = result.toString();
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _result = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return AppPage(
      title: 'Modular Arithmetic',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Fields
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inputs',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildNumberInput(
                  'Number A',
                  _aController,
                  'First operand',
                  Icons.looks_one,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildNumberInput(
                  'Number B',
                  _bController,
                  'Second operand (or exponent)',
                  Icons.looks_two,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildNumberInput(
                  'Modulo M',
                  _modController,
                  'Modulus value',
                  Icons.percent,
                  theme,
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
                    _buildOperationButton(
                      '(A + B) mod M',
                      'add',
                      Icons.add,
                      theme.success,
                      theme,
                    ),
                    _buildOperationButton(
                      '(A − B) mod M',
                      'sub',
                      Icons.remove,
                      theme.warning,
                      theme,
                    ),
                    _buildOperationButton(
                      '(A × B) mod M',
                      'mul',
                      Icons.close,
                      theme.primary,
                      theme,
                    ),
                    _buildOperationButton(
                      'A^B mod M',
                      'pow',
                      Icons.functions,
                      theme.accent,
                      theme,
                    ),
                    _buildOperationButton(
                      'A^(-1) mod M',
                      'inv',
                      Icons.swap_horiz,
                      theme.secondary,
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Result or Error
          if (_error.isNotEmpty)
            ThemedCard(
              color: theme.error.withOpacity(0.1),
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
                          _error,
                          style: TextStyle(fontSize: 14, color: theme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_result.isNotEmpty)
            ThemedCard(
              color: theme.success.withOpacity(0.1),
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.success, width: 2),
                    ),
                    child: SelectableText(
                      _result,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: theme.foreground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getOperationDescription(),
                      style: TextStyle(fontSize: 14, color: theme.muted),
                      textAlign: TextAlign.center,
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
                    Icon(Icons.info_outline, color: theme.primary, size: 20),
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
                  'Modular arithmetic is a system where numbers "wrap around" upon reaching a certain value (the modulus). It\'s used in cryptography, computer science, and number theory.',
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

  Widget _buildNumberInput(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon,
    dynamic theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.foreground,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.foreground,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: theme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildOperationButton(
    String label,
    String op,
    IconData icon,
    Color color,
    dynamic theme,
  ) {
    final isSelected = _operation == op && _result.isNotEmpty;

    return InkWell(
      onTap: () => _calculate(op),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : theme.panel,
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

  String _getOperationDescription() {
    if (_aController.text.isEmpty || _modController.text.isEmpty) {
      return '';
    }

    final a = _aController.text;
    final b = _bController.text;
    final m = _modController.text;

    switch (_operation) {
      case 'add':
        return '($a + $b) mod $m = $_result';
      case 'sub':
        return '($a − $b) mod $m = $_result';
      case 'mul':
        return '($a × $b) mod $m = $_result';
      case 'pow':
        return '$a^$b mod $m = $_result';
      case 'inv':
        return '$a^(-1) mod $m = $_result';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _modController.dispose();
    super.dispose();
  }

  void _unfocusInputs() {
    FocusScope.of(context).unfocus();
  }
}
