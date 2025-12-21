enum AngleMode { rad, deg }

sealed class EvaluationResult {
  const EvaluationResult();
}

class EvalError extends EvaluationResult {
  final EvalErrorType type;
  final String message;
  const EvalError(this.type, this.message);
}

enum EvalErrorType { syntax, divisionByZero, domain, unknown }

class EvalSuccess extends EvaluationResult {
  final double value;
  const EvalSuccess(this.value);
}

class RecursionGuard {
  final int depth;
  final int maxDepth;

  const RecursionGuard(this.depth, this.maxDepth);

  RecursionGuard next() {
    if (depth >= maxDepth) {
      throw const EvalError(
        EvalErrorType.domain,
        'Maximum recursion depth exceeded',
      );
    }
    return RecursionGuard(depth + 1, maxDepth);
  }
}

class FunctionDef {
  final List<String> params;
  final String body;

  const FunctionDef(this.params, this.body);
}
