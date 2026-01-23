import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_function.dart';
import '../services/function_service.dart';
import '../widgets/app_page.dart';
import '../theme/theme_provider.dart';

class CustomFunctionsPage extends StatefulWidget {
  const CustomFunctionsPage({Key? key}) : super(key: key);

  @override
  State<CustomFunctionsPage> createState() => _CustomFunctionsPageState();
}

class _CustomFunctionsPageState extends State<CustomFunctionsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _formulaController = TextEditingController();
  final TextEditingController _paramController = TextEditingController();
  final List<String> _parameters = [];

  void _addParameter() {
    final param = _paramController.text.trim();
    if (param.isEmpty) return;

    // Validate parameter name (alphanumeric + underscore)
    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(param)) {
      _showError(
        'Invalid parameter name. Use letters, numbers, and underscores.',
      );
      return;
    }

    if (_parameters.contains(param)) {
      _showError('Parameter "$param" already added');
      return;
    }

    setState(() {
      _parameters.add(param);
      _paramController.clear();
    });
  }

  void _removeParameter(String param) {
    setState(() {
      _parameters.remove(param);
    });
  }

  void _saveFunction() {
    _unfocusInputs();
    final name = _nameController.text.trim();
    final formula = _formulaController.text.trim();

    // Validation
    if (name.isEmpty) {
      _showError('Please enter a function name');
      return;
    }

    if (!RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$').hasMatch(name)) {
      _showError(
        'Invalid function name. Use letters, numbers, and underscores.',
      );
      return;
    }

    if (formula.isEmpty) {
      _showError('Please enter a formula');
      return;
    }

    if (_parameters.isEmpty) {
      _showError('Please add at least one parameter');
      return;
    }

    final functionService = context.read<FunctionService>();

    // Check if function name already exists
    if (functionService.isDefined(name)) {
      _showError('Function "$name" already exists');
      return;
    }

    // Validate formula by testing with dummy values
    if (!_validateFormula(formula)) {
      return; // Error already shown in _validateFormula
    }

    final newFunc = CustomFunction(
      name: name,
      parameters: List.from(_parameters),
      formula: formula,
    );

    final updated = [...functionService.currentFunctions, newFunc];
    functionService.setFunctions(updated);

    // Clear form
    setState(() {
      _nameController.clear();
      _formulaController.clear();
      _parameters.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Function "$name" saved successfully!'),
        backgroundColor: context.read<ThemeProvider>().currentTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _validateFormula(String formula) {
    final engine = context.read<EvaluationEngine>();

    // Create test context with dummy parameter values
    final testVars = <String, Value>{};
    for (var param in _parameters) {
      testVars[param] = const NumberValue(1.0);
    }

    final testContext = EvalContext(variables: testVars);
    final result = engine.evaluate(formula, testContext);

    if (result is EngineError) {
      _showError('Invalid formula: ${result.message}');
      return false;
    }

    return true;
  }

  void _deleteFunction(int index) {
    final theme = context.read<ThemeProvider>().currentTheme;
    final functionService = context.read<FunctionService>();
    final functions = functionService.currentFunctions;

    if (index < 0 || index >= functions.length) return;

    final funcName = functions[index].name;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.surface,
        title: Text(
          'Delete Function',
          style: TextStyle(color: theme.foreground),
        ),
        content: Text(
          'Are you sure you want to delete "$funcName"?',
          style: TextStyle(color: theme.foreground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: theme.muted)),
          ),
          TextButton(
            onPressed: () {
              functionService.deleteFunction(index);
              setState(() {});
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Function "$funcName" deleted'),
                  backgroundColor: theme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: theme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _testFunction(CustomFunction func) {
    showDialog(
      context: context,
      builder: (_) => _FunctionTestDialog(function: func),
    );
  }

  void _showError(String message) {
    final theme = context.read<ThemeProvider>().currentTheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: theme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final functionService = context.watch<FunctionService>();
    final functions = functionService.currentFunctions;
    final theme = context.watch<ThemeProvider>().currentTheme;

    return AppPage(
      title: 'Custom Functions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Create Function Section
          ThemedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.add_circle, color: theme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Create New Function',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Function Name
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: theme.foreground),
                  decoration: InputDecoration(
                    labelText: 'Function Name',
                    hintText: 'e.g., myFunc, quadratic',
                    prefixIcon: Icon(Icons.functions, color: theme.primary),
                    helperText: 'Letters, numbers, and underscores only',
                    helperStyle: TextStyle(color: theme.muted, fontSize: 11),
                  ),
                ),

                const SizedBox(height: 12),

                // Parameters
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _paramController,
                        style: TextStyle(color: theme.foreground),
                        decoration: InputDecoration(
                          labelText: 'Parameter',
                          hintText: 'e.g., x, y, z',
                          prefixIcon: Icon(Icons.input, color: theme.primary),
                        ),
                        onSubmitted: (_) => _addParameter(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addParameter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primary,
                        foregroundColor: theme.background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Parameter Chips
                if (_parameters.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _parameters.map((p) {
                      return Chip(
                        label: Text(p),
                        backgroundColor: theme.primary.withOpacity(0.2),
                        deleteIconColor: theme.primary,
                        side: BorderSide(color: theme.primary),
                        onDeleted: () => _removeParameter(p),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 12),

                // Formula
                TextField(
                  controller: _formulaController,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: theme.foreground,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Formula',
                    hintText: 'e.g., x^2 + 2*x + 1',
                    prefixIcon: Icon(Icons.code, color: theme.primary),
                    alignLabelWithHint: true,
                    helperText: 'Use parameters defined above',
                    helperStyle: TextStyle(color: theme.muted, fontSize: 11),
                  ),
                ),

                const SizedBox(height: 16),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveFunction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.success,
                      foregroundColor: theme.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, color: theme.background),
                        const SizedBox(width: 8),
                        Text(
                          'Save Function',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Saved Functions Section
          Text(
            'Saved Functions (${functions.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.foreground,
            ),
          ),

          const SizedBox(height: 12),

          if (functions.isEmpty)
            ThemedCard(
              child: Column(
                children: [
                  Icon(Icons.functions, size: 64, color: theme.muted),
                  const SizedBox(height: 16),
                  Text(
                    'No custom functions yet',
                    style: TextStyle(fontSize: 16, color: theme.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first function above!',
                    style: TextStyle(fontSize: 14, color: theme.muted),
                  ),
                ],
              ),
            )
          else
            ...functions.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ThemedCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.functions,
                              color: theme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${f.name}(${f.parameters.join(', ')})',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.foreground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  f.formula,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                    color: theme.muted,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _testFunction(f),
                              icon: Icon(
                                Icons.play_arrow,
                                color: theme.success,
                              ),
                              label: Text(
                                'Test',
                                style: TextStyle(color: theme.success),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.success),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _deleteFunction(i),
                            icon: Icon(Icons.delete, color: theme.error),
                            label: Text(
                              'Delete',
                              style: TextStyle(color: theme.error),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: theme.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _formulaController.dispose();
    _paramController.dispose();
    super.dispose();
  }

  void _unfocusInputs() {
    FocusScope.of(context).unfocus();
  }
}

class _FunctionTestDialog extends StatefulWidget {
  final CustomFunction function;

  const _FunctionTestDialog({required this.function});

  @override
  State<_FunctionTestDialog> createState() => _FunctionTestDialogState();
}

class _FunctionTestDialogState extends State<_FunctionTestDialog> {
  late final List<TextEditingController> _controllers;
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.function.parameters.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _evaluate() {
    setState(() {
      _result = null;
      _error = null;
    });

    // Parse input values
    final values = <Value>[];
    for (var controller in _controllers) {
      final text = controller.text.trim();
      if (text.isEmpty) {
        setState(() => _error = 'Please fill all parameters');
        return;
      }

      final num = double.tryParse(text);
      if (num == null) {
        setState(() => _error = 'Invalid number: $text');
        return;
      }

      values.add(NumberValue(num));
    }

    // Evaluate function
    final functionService = context.read<FunctionService>();
    try {
      final result = functionService.evaluateFunction(
        widget.function.name,
        values,
      );

      if (result != null) {
        setState(() => _result = result.toDisplayString());
      } else {
        setState(() => _error = 'Evaluation failed');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return AlertDialog(
      backgroundColor: theme.surface,
      title: Text(
        'Test ${widget.function.name}',
        style: TextStyle(color: theme.foreground),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formula display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.subtle),
              ),
              child: Text(
                widget.function.formula,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: theme.muted,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parameter inputs
            ...List.generate(widget.function.parameters.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[i],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: TextStyle(color: theme.foreground),
                  decoration: InputDecoration(
                    labelText: widget.function.parameters[i],
                    labelStyle: TextStyle(color: theme.primary),
                    filled: true,
                    fillColor: theme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (_) => _evaluate(),
                ),
              );
            }),

            // Result or Error display
            if (_result != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.success),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: theme.success,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Result:',
                          style: TextStyle(
                            color: theme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _result!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: theme.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.error, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: theme.muted)),
        ),
        ElevatedButton(
          onPressed: _evaluate,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: theme.background,
          ),
          child: const Text('Evaluate'),
        ),
      ],
    );
  }
}
