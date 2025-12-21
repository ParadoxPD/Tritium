import 'package:flutter_test/flutter_test.dart';
import 'package:app/state/calculator_state.dart';
import 'package:app/services/calculator_service.dart';
import 'package:app/services/function_service.dart';
import 'package:app/core/evaluator/expression_evaluator.dart';
import 'package:app/repositories/memory_repository.dart';
import 'package:app/repositories/function_repository.dart';

void main() {
  late CalculatorState state;

  setUp(() {
    state = CalculatorState(
      CalculatorService(ExpressionEvaluator(), MemoryRepository()),
      FunctionService(FunctionRepository()),
    );
  });

  test('simple input and evaluate', () {
    state.input('2');
    state.input('+');
    state.input('3');
    state.input('=');

    expect(state.display, '5');
  });

  test('clear resets state', () {
    state.input('9');
    state.input('C');

    expect(state.display, '0');
    expect(state.expression, '');
  });
}
