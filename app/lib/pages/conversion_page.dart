import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/unit_conversions.dart';
import '../widgets/app_page.dart';
import '../theme/theme_provider.dart';

class ConversionPage extends StatefulWidget {
  const ConversionPage({Key? key}) : super(key: key);

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  final TextEditingController _inputController = TextEditingController();
  String _category = 'Length';
  String _fromUnit = 'meter';
  String _toUnit = 'kilometer';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_autoConvert);
  }

  void _autoConvert() {
    if (_inputController.text.isNotEmpty) {
      _convert();
    } else {
      setState(() => _result = '');
    }
  }

  void _convert() {
    try {
      final input = double.parse(_inputController.text);
      final result = UnitConversions.convert(
        input,
        _category,
        _fromUnit,
        _toUnit,
      );

      setState(() {
        _result = result.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
      });
    } catch (e) {
      setState(() {
        _result = '';
      });
    }
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _convert();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final units = UnitConversions.getUnitsForCategory(_category);

    return AppPage(
      title: 'Unit Converter',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category Selection
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.panel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.subtle),
                  ),
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: theme.panel,
                    style: TextStyle(fontSize: 16, color: theme.foreground),
                    icon: Icon(Icons.arrow_drop_down, color: theme.primary),
                    items: UnitConversions.categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(
                              _getCategoryIcon(c),
                              size: 20,
                              color: theme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(c, style: TextStyle(color: theme.foreground)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _category = v!;
                        final newUnits = UnitConversions.getUnitsForCategory(
                          _category,
                        );
                        _fromUnit = newUnits[0];
                        _toUnit = newUnits.length > 1
                            ? newUnits[1]
                            : newUnits[0];
                        _convert();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input Value
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixIcon: Icon(Icons.edit, color: theme.primary),
                    suffixIcon: _inputController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: theme.muted),
                            onPressed: () {
                              _inputController.clear();
                              setState(() => _result = '');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Unit Selection
          ThemedCard(
            child: Column(
              children: [
                // From Unit
                _buildUnitSelector(
                  'From',
                  _fromUnit,
                  units,
                  (v) => setState(() {
                    _fromUnit = v!;
                    _convert();
                  }),
                  theme,
                ),

                const SizedBox(height: 12),

                // Swap Button
                Center(
                  child: IconButton(
                    onPressed: _swapUnits,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.primary),
                      ),
                      child: Icon(
                        Icons.swap_vert,
                        color: theme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // To Unit
                _buildUnitSelector(
                  'To',
                  _toUnit,
                  units,
                  (v) => setState(() {
                    _toUnit = v!;
                    _convert();
                  }),
                  theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Result
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          _result,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: theme.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatUnitName(_toUnit),
                          style: TextStyle(fontSize: 16, color: theme.muted),
                        ),
                      ],
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
                      '${_inputController.text} ${_formatUnitName(_fromUnit)} = $_result ${_formatUnitName(_toUnit)}',
                      style: TextStyle(fontSize: 14, color: theme.muted),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector(
    String label,
    String value,
    List<String> units,
    Function(String?) onChanged,
    dynamic theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.subtle),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.muted,
              ),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: theme.panel,
              style: TextStyle(fontSize: 16, color: theme.foreground),
              items: units.map((u) {
                return DropdownMenuItem(
                  value: u,
                  child: Text(
                    _formatUnitName(u),
                    style: TextStyle(color: theme.foreground),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Length':
        return Icons.straighten;
      case 'Weight':
        return Icons.fitness_center;
      case 'Temperature':
        return Icons.thermostat;
      case 'Area':
        return Icons.crop_square;
      case 'Volume':
        return Icons.water_drop;
      default:
        return Icons.calculate;
    }
  }

  String _formatUnitName(String unit) {
    return unit
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  void dispose() {
    _inputController.removeListener(_autoConvert);
    _inputController.dispose();
    super.dispose();
  }
}
