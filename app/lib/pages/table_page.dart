import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  State<TablePage> createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final TextEditingController _fxController = TextEditingController();
  final TextEditingController _gxController = TextEditingController();
  final TextEditingController _startController = TextEditingController(
    text: '0',
  );
  final TextEditingController _endController = TextEditingController(
    text: '10',
  );
  final TextEditingController _stepController = TextEditingController(
    text: '1',
  );

  bool _useTwoFunctions = false;
  final List<Map<String, double>> _tableData = [];
  String? _error;

  @override
  void dispose() {
    _fxController.dispose();
    _gxController.dispose();
    _startController.dispose();
    _endController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _generateTable() {
    setState(() {
      _error = null;
      _tableData.clear();
    });

    final fx = _fxController.text.trim();
    if (fx.isEmpty) {
      setState(() => _error = 'Enter f(x)');
      return;
    }

    final start = double.tryParse(_startController.text);
    final end = double.tryParse(_endController.text);
    final step = double.tryParse(_stepController.text);

    if (start == null || end == null || step == null || step == 0) {
      setState(() => _error = 'Invalid range or step');
      return;
    }

    if ((end - start) / step > 1000) {
      setState(() => _error = 'Too many points (max 1000)');
      return;
    }

    final engine = context.read<EvaluationEngine>();

    try {
      for (double x = start; x <= end; x += step) {
        final row = <String, double>{'x': x};

        // Create context with x variable
        final evalContext = EvalContext(variables: {'x': NumberValue(x)});

        // Evaluate f(x)
        final fResult = engine.evaluate(fx, evalContext);

        if (fResult is EngineSuccess) {
          final numValue = fResult.value.toDouble();
          row['f(x)'] = numValue ?? double.nan;
        } else {
          row['f(x)'] = double.nan;
        }

        // Evaluate g(x) if enabled
        if (_useTwoFunctions && _gxController.text.isNotEmpty) {
          final gx = _gxController.text.trim();
          final gResult = engine.evaluate(gx, evalContext);

          if (gResult is EngineSuccess) {
            final numValue = gResult.value.toDouble();
            row['g(x)'] = numValue ?? double.nan;
          } else {
            row['g(x)'] = double.nan;
          }
        }

        setState(() => _tableData.add(row));
      }
    } catch (e) {
      setState(() => _error = 'Evaluation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Table Generator'),
        backgroundColor: theme.surface,
        foregroundColor: theme.foreground,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.settings, color: theme.muted),
            color: theme.surface,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: StatefulBuilder(
                  builder: (context, setState) => SwitchListTile(
                    title: Text(
                      'Two Functions',
                      style: TextStyle(color: theme.foreground),
                    ),
                    subtitle: Text(
                      'f(x) and g(x)',
                      style: TextStyle(color: theme.muted, fontSize: 12),
                    ),
                    value: _useTwoFunctions,
                    activeThumbColor: theme.primary,
                    onChanged: (val) {
                      setState(() => _useTwoFunctions = val);
                      this.setState(() => _useTwoFunctions = val);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Function input
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Function Definition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _fxController,
                  style: TextStyle(
                    color: theme.foreground,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    labelText: 'f(x)',
                    hintText: 'e.g., x^2 + 2*x + 1',
                    labelStyle: TextStyle(color: theme.primary),
                    hintStyle: TextStyle(
                      color: theme.muted.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_useTwoFunctions) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _gxController,
                    style: TextStyle(
                      color: theme.foreground,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      labelText: 'g(x)',
                      hintText: 'e.g., sin(x)',
                      labelStyle: TextStyle(color: theme.primary),
                      hintStyle: TextStyle(
                        color: theme.muted.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: theme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Range settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              border: Border(top: BorderSide(color: theme.subtle)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Table Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        style: TextStyle(color: theme.foreground),
                        decoration: InputDecoration(
                          labelText: 'Start',
                          labelStyle: TextStyle(color: theme.primary),
                          filled: true,
                          fillColor: theme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _endController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        style: TextStyle(color: theme.foreground),
                        decoration: InputDecoration(
                          labelText: 'End',
                          labelStyle: TextStyle(color: theme.primary),
                          filled: true,
                          fillColor: theme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _stepController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        style: TextStyle(color: theme.foreground),
                        decoration: InputDecoration(
                          labelText: 'Step',
                          labelStyle: TextStyle(color: theme.primary),
                          filled: true,
                          fillColor: theme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generateTable,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: theme.background,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.table_chart),
                    label: const Text('GENERATE TABLE'),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: theme.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!, style: TextStyle(color: theme.error)),
                  ),
                ],
              ),
            ),

          // Table display
          Expanded(
            child: _tableData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.table_chart_outlined,
                          size: 80,
                          color: theme.muted.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No table generated',
                          style: TextStyle(color: theme.muted, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter function and generate',
                          style: TextStyle(
                            color: theme.muted.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(theme.surface),
                        dataRowColor: WidgetStateProperty.all(theme.background),
                        border: TableBorder.all(color: theme.subtle, width: 1),
                        columns: [
                          DataColumn(
                            label: Text(
                              'x',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'f(x)',
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (_useTwoFunctions)
                            DataColumn(
                              label: Text(
                                'g(x)',
                                style: TextStyle(
                                  color: theme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                        rows: _tableData.map((row) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  _format(row['x']!),
                                  style: TextStyle(
                                    color: theme.foreground,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _format(row['f(x)']!),
                                  style: TextStyle(
                                    color: theme.foreground,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              if (_useTwoFunctions)
                                DataCell(
                                  Text(
                                    _format(row['g(x)']!),
                                    style: TextStyle(
                                      color: theme.foreground,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _format(double val) {
    if (val.isNaN) return 'ERROR';
    if (val.isInfinite) return val > 0 ? '∞' : '-∞';
    if (val.abs() >= 1e6 || (val.abs() < 1e-4 && val != 0)) {
      return val.toStringAsExponential(4);
    }
    return val.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
