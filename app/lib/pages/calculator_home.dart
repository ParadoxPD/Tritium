import 'package:app/core/engine.dart';
import 'package:app/services/calculator_service.dart';
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
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  int _selectedIndex = 0;

  // Don't use 'late final' - just use nullable with lazy initialization
  CalculatorService? _calculatorService;

  CalculatorService _getCalculatorService(BuildContext context) {
    // Lazy initialization - only create once
    if (_calculatorService == null) {
      final engine = context.read<EvaluationEngine>();
      _calculatorService = CalculatorService(engine);
    }
    return _calculatorService!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final calculatorService = _getCalculatorService(context);

    return MultiProvider(
      providers: [
        // FunctionService and EvaluationEngine are already provided from main.dart
        Provider<CalculatorService>.value(value: calculatorService),
        // ConversionService is already provided from main.dart
        ChangeNotifierProvider(
          create: (_) => CalculatorState(context.read<EvaluationEngine>()),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(index: _selectedIndex, children: _pages),
        ),
        backgroundColor: theme.background,
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
