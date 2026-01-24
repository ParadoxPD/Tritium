import 'package:app/core/engine.dart';
import 'package:app/repositories/function_repository.dart';
import 'package:app/services/conversion_service.dart';
import 'package:app/services/function_service.dart';
import 'package:app/state/calculator_state.dart';
import 'package:app/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/calculator_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create core engine
  final engine = EvaluationEngine();

  // Create repositories
  final functionRepo = FunctionRepository();

  // Create services
  final functionService = FunctionService(functionRepo, engine);
  final conversionService = ConversionService();

  // Restore saved data
  await functionService.restore();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorState(engine)),
        Provider<EvaluationEngine>.value(value: engine),
        Provider<FunctionService>.value(value: functionService),
        ChangeNotifierProvider<ConversionService>.value(
          value: conversionService,
        ),
      ],
      child: const CalculatorApp(),
    ),
  );
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        return AnimatedTheme(
          data: provider.theme,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: MaterialApp(
            title: "Tritium",
            theme: provider.theme,
            darkTheme: provider.theme,
            themeMode: provider.currentThemeGroup,
            home: const CalculatorHome(),
          ),
        );
      },
    );
  }
}
