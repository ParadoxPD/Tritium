import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_page.dart';
import '../theme/theme_provider.dart';

class BaseNCalculatorPage extends StatefulWidget {
  const BaseNCalculatorPage({Key? key}) : super(key: key);

  @override
  State<BaseNCalculatorPage> createState() => _BaseNCalculatorPageState();
}

class _BaseNCalculatorPageState extends State<BaseNCalculatorPage> {
  final TextEditingController _inputController = TextEditingController();
  int _fromBase = 10;
  int _toBase = 2;
  String _result = '';
  String _error = '';

  final List<int> _bases = [2, 8, 10, 16];
  final Map<int, String> _baseNames = {
    2: 'Binary',
    8: 'Octal',
    10: 'Decimal',
    16: 'Hexadecimal',
  };

  void _convert() {
    _unfocusInputs();
    setState(() {
      _error = '';
      _result = '';
    });

    try {
      final input = _inputController.text.toUpperCase().trim();

      if (input.isEmpty) {
        setState(() {
          _error = 'Please enter a number';
        });
        return;
      }

      final decimal = int.parse(input, radix: _fromBase);
      final converted = decimal.toRadixString(_toBase).toUpperCase();

      setState(() {
        _result = converted;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid input for base $_fromBase';
        _result = '';
      });
    }
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _result = '';
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return AppPage(
      title: 'Base-N Converter',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Section
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _inputController,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'monospace',
                    color: theme.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter number...',
                    prefixIcon: Icon(Icons.input, color: theme.primary),
                    suffixIcon: _inputController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: theme.muted),
                            onPressed: _clear,
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _convert(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Base Selection
          ThemedCard(
            child: Column(
              children: [
                _buildBaseSelector(
                  'From',
                  _fromBase,
                  (v) => setState(() => _fromBase = v!),
                  theme,
                ),
                const SizedBox(height: 16),
                Icon(Icons.arrow_downward, color: theme.primary, size: 28),
                const SizedBox(height: 16),
                _buildBaseSelector(
                  'To',
                  _toBase,
                  (v) => setState(() => _toBase = v!),
                  theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Convert Button
          ElevatedButton(
            onPressed: _convert,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.background,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calculate, color: theme.background),
                const SizedBox(width: 8),
                Text(
                  'Convert',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.background,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Result Section
          if (_error.isNotEmpty)
            ThemedCard(
              color: theme.error.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.error,
                        fontWeight: FontWeight.w500,
                      ),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.panel,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.success, width: 2),
                    ),
                    child: SelectableText(
                      _result,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: theme.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_baseNames[_toBase]} (Base $_toBase)',
                    style: TextStyle(fontSize: 14, color: theme.muted),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Quick Reference
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Reference',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: theme.muted,
                  ),
                ),
                const SizedBox(height: 8),
                _buildReferenceRow('Binary (Base 2)', '0-1', theme),
                _buildReferenceRow('Octal (Base 8)', '0-7', theme),
                _buildReferenceRow('Decimal (Base 10)', '0-9', theme),
                _buildReferenceRow('Hexadecimal (Base 16)', '0-9, A-F', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseSelector(
    String label,
    int value,
    Function(int?) onChanged,
    dynamic theme,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.foreground,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.subtle),
            ),
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: theme.panel,
              style: TextStyle(fontSize: 16, color: theme.foreground),
              items: _bases.map((base) {
                return DropdownMenuItem(
                  value: base,
                  child: Text(
                    '${_baseNames[base]} ($base)',
                    style: TextStyle(color: theme.foreground),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceRow(String name, String digits, dynamic theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 12, color: theme.muted),
            ),
          ),
          Text(
            digits,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: theme.muted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _unfocusInputs() {
    FocusScope.of(context).unfocus();
  }
}
