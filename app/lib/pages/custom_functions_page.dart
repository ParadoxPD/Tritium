import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/custom_function.dart';
import '../services/function_service.dart';
import '../widgets/function_test_dialog.dart';

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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Function saved!')));
  }

  void _deleteFunction(int index) {
    final functionService = context.read<FunctionService>();
    final updated = List<CustomFunction>.from(functionService.currentFunctions)
      ..removeAt(index);

    functionService.setFunctions(updated);
    setState(() {});
  }

  void _testFunction(CustomFunction func) {
    showDialog(
      context: context,
      builder: (_) => FunctionTestDialog(function: func),
    );
  }

  @override
  Widget build(BuildContext context) {
    final functionService = context.watch<FunctionService>();
    final functions = functionService.currentFunctions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Custom Function',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Function Name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _paramController,
                  decoration: const InputDecoration(
                    labelText: 'Parameter',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addParameter,
                child: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _parameters
                .map(
                  (p) => Chip(
                    label: Text(p),
                    onDeleted: () {
                      setState(() => _parameters.remove(p));
                    },
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 12),
          TextField(
            controller: _formulaController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Formula',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveFunction,
            child: const Text('Save Function'),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Saved Functions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (functions.isEmpty)
            const Text('No custom functions yet', textAlign: TextAlign.center)
          else
            ...functions.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              return Card(
                child: ListTile(
                  title: Text('${f.name}(${f.parameters.join(', ')})'),
                  subtitle: Text(f.formula),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () => _testFunction(f),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteFunction(i),
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
}
