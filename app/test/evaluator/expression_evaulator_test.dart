import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/evaluator/expression_evaluator.dart';
import 'package:app/core/evaluator/eval_context.dart';
import 'package:app/core/evaluator/eval_types.dart';

void main() {
  final evaluator = ExpressionEvaluator();

  test('basic arithmetic', () {
    final r =
        evaluator.evaluate('2+3*4', AngleMode.rad, context: const EvalContext())
            as EvalSuccess;

    expect(r.value, 14);
  });

  test('parentheses precedence', () {
    final r =
        evaluator.evaluate(
              '(2+3)*4',
              AngleMode.rad,
              context: const EvalContext(),
            )
            as EvalSuccess;

    expect(r.value, 20);
  });

  test('power operator', () {
    final r =
        evaluator.evaluate('2^3^2', AngleMode.rad, context: const EvalContext())
            as EvalSuccess;

    expect(r.value, 512); // right associative
  });

  test('division by zero', () {
    final r = evaluator.evaluate(
      '5/0',
      AngleMode.rad,
      context: const EvalContext(),
    );

    expect(r, isA<EvalError>());
    expect((r as EvalError).type, EvalErrorType.divisionByZero);
  });
}
