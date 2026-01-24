// ============================================================================
// FILE: core/engine_result.dart
// Result types for the entire engine
// ============================================================================

import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';

sealed class EngineResult {
  const EngineResult();
}

class EngineSuccess extends EngineResult {
  final Value value;
  final EvalContext context; // Updated context with new variables

  const EngineSuccess(this.value, this.context);
}

class EngineError extends EngineResult {
  final ErrorType type;
  final String message;
  final int? position; // Character position in input
  final String? hint; // Helpful suggestion

  const EngineError(this.type, this.message, {this.position, this.hint});

  @override
  String toString() {
    final buf = StringBuffer(message);
    if (position != null) buf.write(' at position $position');
    if (hint != null) buf.write('\nHint: $hint');
    return buf.toString();
  }
}

enum ErrorType {
  // Parse errors
  unexpectedToken,
  unexpectedEndOfInput,
  invalidSyntax,

  // Binding errors
  undefinedVariable,
  undefinedFunction,
  typeMismatch,
  wrongArgumentCount,

  // Runtime errors
  divisionByZero,
  domainError,
  dimensionMismatch,
  overflow,
  recursionLimit,

  // General
  unknown,
  runtime,
}
