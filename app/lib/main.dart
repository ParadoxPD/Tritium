import 'package:app/core/evaluator/expression_evaluator.dart';
import 'package:app/repositories/function_repository.dart';
import 'package:app/repositories/memory_repository.dart';
import 'package:app/services/calculator_service.dart';
import 'package:app/services/function_service.dart';
import 'package:flutter/material.dart';
import 'pages/calculator_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final evaluator = ExpressionEvaluator();
  final memoryRepo = MemoryRepository();
  final functionRepo = FunctionRepository();

  final calculatorService = CalculatorService(evaluator, memoryRepo);
  final functionService = FunctionService(functionRepo);

  await calculatorService.restore();
  await functionService.restore();

  runApp(
    CalculatorApp(
      calculatorService: calculatorService,
      functionService: functionService,
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  final CalculatorService calculatorService;
  final FunctionService functionService;

  const CalculatorApp({
    Key? key,
    required this.calculatorService,
    required this.functionService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scientific Calculator',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1E1E1E),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF03DAC6),
        ),
      ),
      home: CalculatorHome(
        calculatorService: calculatorService,
        functionService: functionService,
      ),
    );
  }
}
