import 'package:app/services/calculator_service.dart';
import 'package:app/services/conversion_service.dart';
import 'package:app/services/function_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'scientific_calculator_page.dart';
import 'modulo_calculator_page.dart';
import 'matrix_calculator_page.dart';
import 'base_n_calculator_page.dart';
import 'conversion_page.dart';
import 'custom_functions_page.dart';
import '../state/calculator_state.dart';
import '../theme/theme_provider.dart';

class CalculatorHome extends StatefulWidget {
  final CalculatorService calculatorService;
  final FunctionService functionService;
  final ConversionService conversionService;

  const CalculatorHome({
    super.key,
    required this.calculatorService,
    required this.functionService,
    required this.conversionService,
  });

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return MultiProvider(
      providers: [
        Provider<FunctionService>.value(value: widget.functionService),
        Provider<CalculatorService>.value(value: widget.calculatorService),

        ChangeNotifierProvider<ConversionService>.value(
          value: widget.conversionService,
        ),

        ChangeNotifierProvider(
          create: (_) =>
              CalculatorState(widget.calculatorService, widget.functionService),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
        backgroundColor: theme.surface,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              backgroundColor: Colors.transparent,
              selectedItemColor: theme.primary,
              unselectedItemColor: theme.muted,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                _buildNavItem(
                  icon: Icons.calculate,
                  label: 'Calculator',
                  isSelected: _selectedIndex == 0,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.percent,
                  label: 'Modulo',
                  isSelected: _selectedIndex == 1,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.grid_on,
                  label: 'Matrix',
                  isSelected: _selectedIndex == 2,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.tag,
                  label: 'Base N',
                  isSelected: _selectedIndex == 3,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.swap_horiz,
                  label: 'Convert',
                  isSelected: _selectedIndex == 4,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: Icons.functions,
                  label: 'Functions',
                  isSelected: _selectedIndex == 5,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required dynamic theme,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? theme.primary : theme.muted,
        ),
      ),
      label: label,
    );
  }

  List<Widget> get _pages => [
    const ScientificCalculatorPage(),
    const ModuloCalculatorPage(),
    const MatrixCalculatorPage(),
    const BaseNCalculatorPage(),
    const ConversionPage(),
    const CustomFunctionsPage(),
  ];
}
