import 'package:app/core/engine.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';

class CalculatorService {
  final EvaluationEngine engine;

  CalculatorService(this.engine);

  EngineResult evaluate(
    String input,
    AngleMode angleMode,
    EvalContext context,
  ) {
    // Update context with current angle mode
    final updatedContext = context.copyWith(angleMode: angleMode);
    return engine.evaluate(input, updatedContext);
  }
}
