import 'package:flutter/material.dart';
import '../utils/modulo_operations.dart';

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

  void _calculate(String operation) {
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
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _aController,
            decoration: const InputDecoration(labelText: 'Number A'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _bController,
            decoration: const InputDecoration(labelText: 'Number B'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _modController,
            decoration: const InputDecoration(labelText: 'Modulo'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _calculate('add'),
                child: const Text('(A + B) mod M'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('sub'),
                child: const Text('(A - B) mod M'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('mul'),
                child: const Text('(A × B) mod M'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('pow'),
                child: const Text('A^B mod M'),
              ),
              ElevatedButton(
                onPressed: () => _calculate('inv'),
                child: const Text('A^(-1) mod M'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Result: $_result',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
