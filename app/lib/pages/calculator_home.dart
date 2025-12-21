import 'package:app/core/evaluator/eval_types.dart';
import 'package:app/models/custom_function.dart';
import 'package:app/services/calculator_service.dart';
import 'package:app/services/function_service.dart';
import 'package:flutter/material.dart';
import 'scientific_calculator_page.dart';
import 'modulo_calculator_page.dart';
import 'matrix_calculator_page.dart';
import 'base_n_calculator_page.dart';
import 'conversion_page.dart';
import 'custom_functions_page.dart';

import 'package:provider/provider.dart';

import '../state/calculator_state.dart';

class CalculatorHome extends StatefulWidget {
  final CalculatorService calculatorService;
  final FunctionService functionService;

  const CalculatorHome({
    super.key,
    required this.calculatorService,
    required this.functionService,
  });

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CalculatorState(widget.calculatorService, widget.functionService),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Calculator',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.functions),
              label: 'Functions',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _pages => const [
    ScientificCalculatorPage(),
    ModuloCalculatorPage(),
    MatrixCalculatorPage(),
    BaseNCalculatorPage(),
    ConversionPage(),
    CustomFunctionsPage(),
  ];
}
