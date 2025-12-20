import 'package:flutter/material.dart';
import '../utils/unit_conversions.dart';

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
        _result = result.toStringAsFixed(6);
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = UnitConversions.getUnitsForCategory(_category);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButton<String>(
            value: _category,
            isExpanded: true,
            items: UnitConversions.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              setState(() {
                _category = v!;
                final units = UnitConversions.getUnitsForCategory(_category);
                _fromUnit = units[0];
                _toUnit = units[1];
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _fromUnit,
                  isExpanded: true,
                  items: units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _fromUnit = v!),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward),
              ),
              Expanded(
                child: DropdownButton<String>(
                  value: _toUnit,
                  isExpanded: true,
                  items: units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => _toUnit = v!),
                ),
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
