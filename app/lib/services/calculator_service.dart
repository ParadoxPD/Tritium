import 'package:app/core/evaluator/eval_context.dart';
import 'package:app/core/evaluator/eval_types.dart';
import 'package:app/repositories/memory_repository.dart';

import '../core/evaluator/expression_evaluator.dart';

class CalculatorService {
  final ExpressionEvaluator _evaluator;
  final MemoryRepository _memoryRepo;

  double? _ans;
  double _memory = 0.0;

  CalculatorService(this._evaluator, this._memoryRepo);

  Future<void> restore() async {
    _memory = await _memoryRepo.loadMemory();
    _ans = await _memoryRepo.loadANS();
  }

  EvaluationResult evaluate(
    String expression,
    AngleMode mode,
    EvalContext context,
  ) {
    final result = _evaluator.evaluate(expression, mode, context: context);

    if (result is EvalSuccess) {
      _ans = result.value;
      _memoryRepo.saveANS(_ans!);
    }

    return result;
  }

  void memoryClear() {
    _memory = 0.0;
    _memoryRepo.saveMemory(_memory);
  }

  void memoryAdd() {
    if (_ans != null) {
      _memory += _ans!;
      _memoryRepo.saveMemory(_memory);
    }
  }

  void memorySubtract() {
    if (_ans != null) {
      _memory -= _ans!;
      _memoryRepo.saveMemory(_memory);
    }
  }

  double memoryRecall() => _memory;
}
