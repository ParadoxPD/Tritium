import 'package:flutter/material.dart';
import 'scientific_calculator_page.dart';
import 'modulo_calculator_page.dart';
import 'matrix_calculator_page.dart';
import 'base_n_calculator_page.dart';
import 'conversion_page.dart';
import 'custom_functions_page.dart';

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({Key? key}) : super(key: key);

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ScientificCalculatorPage(),
    const ModuloCalculatorPage(),
    const MatrixCalculatorPage(),
    const BaseNCalculatorPage(),
    const ConversionPage(),
    const CustomFunctionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scientific Calculator'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate),
            label: 'Scientific',
          ),
          NavigationDestination(icon: Icon(Icons.percent), label: 'Modulo'),
          NavigationDestination(icon: Icon(Icons.grid_on), label: 'Matrix'),
          NavigationDestination(icon: Icon(Icons.tag), label: 'Base N'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Convert'),
          NavigationDestination(icon: Icon(Icons.functions), label: 'Custom'),
        ],
      ),
    );
  }
}
