import 'package:app/core/evaluator/expression_evaluator.dart';
import 'package:app/repositories/function_repository.dart';
import 'package:app/repositories/memory_repository.dart';
import 'package:app/services/calculator_service.dart';
import 'package:app/services/conversion_service.dart';
import 'package:app/services/function_service.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/calculator_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final evaluator = ExpressionEvaluator();
  final memoryRepo = MemoryRepository();
  final functionRepo = FunctionRepository();

  final calculatorService = CalculatorService(evaluator, memoryRepo);
  final functionService = FunctionService(functionRepo);
  final conversionService = ConversionService();

  await calculatorService.restore();
  await functionService.restore();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: CalculatorApp(
        calculatorService: calculatorService,
        functionService: functionService,
        conversionService: conversionService,
      ),
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  final CalculatorService calculatorService;
  final FunctionService functionService;
  final ConversionService conversionService;

  const CalculatorApp({
    Key? key,
    required this.calculatorService,
    required this.functionService,
    required this.conversionService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Scientific Calculator',
      theme: theme.theme,
      home: CalculatorHome(
        calculatorService: calculatorService,
        functionService: functionService,
        conversionService: conversionService,
      ),
    );
  }
}
