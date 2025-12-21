import 'package:flutter_test/flutter_test.dart';
import 'package:app/state/calculator_state.dart';
import 'package:app/services/calculator_service.dart';
import 'package:app/services/function_service.dart';
import 'package:app/core/evaluator/expression_evaluator.dart';
import 'package:app/repositories/memory_repository.dart';
import 'package:app/repositories/function_repository.dart';

void main() {
  late CalculatorState state;

  setUp(() async {
    final calcService = CalculatorService(
      ExpressionEvaluator(),
      MemoryRepository(),
    );
    final funcService = FunctionService(FunctionRepository());

    state = CalculatorState(calcService, funcService);
  });

  test('cannot start with operator', () {
    state.input('*');
    expect(state.expression, '');
  });

  test('only one decimal per number', () {
    state.input('1');
    state.input('.');
    state.input('.');
    state.input('2');

    expect(state.expression, '1.2');
  });

  test('parentheses balance enforced', () {
    state.input(')');
    expect(state.expression, '');
  });
}
