// ============================================================================
// FILE: core/engine/evaluator/runtime_errors.dart
// ============================================================================

class RuntimeError extends Error {
  final String message;
  RuntimeError(this.message);

  @override
  String toString() => 'Runtime Error: $message';
}
