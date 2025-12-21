import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/calculator_service.dart';
import 'package:app/core/evaluator/expression_evaluator.dart';
import 'package:app/repositories/memory_repository.dart';
import 'package:app/core/evaluator/eval_context.dart';
import 'package:app/core/evaluator/eval_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late CalculatorService service;

  setUp(() {
    service = CalculatorService(ExpressionEvaluator(), MemoryRepository());
  });

  test('ANS updates after evaluation', () {
    final r =
        service.evaluate('2+3', AngleMode.rad, const EvalContext())
            as EvalSuccess;

    expect(r.value, 5);
    expect(service.ans, 5);
  });

  test('memory add and recall', () {
    service.evaluate('10', AngleMode.rad, const EvalContext());
    service.memoryAdd();

    expect(service.memoryRecall(), 10);
  });
}
