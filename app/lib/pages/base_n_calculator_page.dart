import 'package:flutter/material.dart';

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

  void _convert() {
    try {
      final input = _inputController.text.toUpperCase();
      final decimal = int.parse(input, radix: _fromBase);
      final converted = decimal.toRadixString(_toBase).toUpperCase();

      setState(() {
        _result = converted;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: Invalid input';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Input Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('From base: '),
              DropdownButton<int>(
                value: _fromBase,
                items: [2, 8, 10, 16]
                    .map((b) => DropdownMenuItem(value: b, child: Text('$b')))
                    .toList(),
                onChanged: (v) => setState(() => _fromBase = v!),
              ),
              const SizedBox(width: 20),
              const Text('To base: '),
              DropdownButton<int>(
                value: _toBase,
                items: [2, 8, 10, 16]
                    .map((b) => DropdownMenuItem(value: b, child: Text('$b')))
                    .toList(),
                onChanged: (v) => setState(() => _toBase = v!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _convert, child: const Text('Convert')),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Result: $_result',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
