import 'package:app/utils/expression_evaluator.dart';
import 'package:flutter/material.dart';
import '../models/custom_function.dart';
import '../widgets/function_test_dialog.dart';

class CustomFunctionsPage extends StatefulWidget {
  final Map<String, FunctionDef> functions;
  final void Function(List<CustomFunction>) onFunctionsUpdated;

  const CustomFunctionsPage({
    Key? key,
    required this.functions,
    required this.onFunctionsUpdated,
  }) : super(key: key);

  @override
  State<CustomFunctionsPage> createState() => _CustomFunctionsPageState();
}

class _CustomFunctionsPageState extends State<CustomFunctionsPage> {
  final List<CustomFunction> _functions = [];
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
    if (_nameController.text.isNotEmpty &&
        _formulaController.text.isNotEmpty &&
        _parameters.isNotEmpty) {
      setState(() {
        _functions.add(
          CustomFunction(
            name: _nameController.text,
            parameters: List.from(_parameters),
            formula: _formulaController.text,
          ),
        );
        _nameController.clear();
        _formulaController.clear();
        _parameters.clear();
      });
      widget.onFunctionsUpdated(_functions);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Function saved!')));
    }
  }

  void _deleteFunction(int index) {
    setState(() {
      _functions.removeAt(index);
    });

    widget.onFunctionsUpdated(_functions);
  }

  void _testFunction(CustomFunction func) {
    showDialog(
      context: context,
      builder: (context) =>
          FunctionTestDialog(function: func, functions: widget.functions),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              hintText: 'e.g., quadratic',
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
                    hintText: 'e.g., x',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addParameter,
                child: const Text('Add Param'),
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
                      setState(() {
                        _parameters.remove(p);
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _formulaController,
            decoration: const InputDecoration(
              labelText: 'Formula',
              hintText: 'e.g., a*x^2 + b*x + c',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _saveFunction,
            icon: const Icon(Icons.save),
            label: const Text('Save Function'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Saved Functions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_functions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No custom functions yet. Create one above!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._functions.asMap().entries.map((entry) {
              final index = entry.key;
              final func = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    '${func.name}(${func.parameters.join(', ')})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Formula: ${func.formula}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green),
                        onPressed: () => _testFunction(func),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFunction(index),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
