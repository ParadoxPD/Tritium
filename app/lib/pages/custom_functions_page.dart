import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_function.dart';
import '../services/function_service.dart';
import '../widgets/function_test_dialog.dart';
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
    if (_paramController.text.isNotEmpty) {
      setState(() {
        _parameters.add(_paramController.text);
        _paramController.clear();
      });
    }
  }

  void _saveFunction() {
    if (_nameController.text.isEmpty ||
        _formulaController.text.isEmpty ||
        _parameters.isEmpty) {
      _showError('Please fill all fields and add at least one parameter');
      return;
    }

    final functionService = context.read<FunctionService>();

    final newFunc = CustomFunction(
      name: _nameController.text,
      parameters: List.from(_parameters),
      formula: _formulaController.text,
    );

    final updated = [...functionService.currentFunctions, newFunc];
    functionService.setFunctions(updated);

    setState(() {
      _nameController.clear();
      _formulaController.clear();
      _parameters.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Function saved successfully!'),
        backgroundColor: context.read<ThemeProvider>().currentTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteFunction(int index) {
    final theme = context.read<ThemeProvider>().currentTheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Function'),
        content: const Text('Are you sure you want to delete this function?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final functionService = context.read<FunctionService>();
              final updated = List<CustomFunction>.from(
                functionService.currentFunctions,
              )..removeAt(index);

              functionService.setFunctions(updated);
              setState(() {});
              Navigator.pop(ctx);
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
      builder: (_) => FunctionTestDialog(function: func),
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
                    hintText: 'e.g., myFunc',
                    prefixIcon: Icon(Icons.functions, color: theme.primary),
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
                          hintText: 'e.g., x',
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
                        onDeleted: () {
                          setState(() => _parameters.remove(p));
                        },
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
}
