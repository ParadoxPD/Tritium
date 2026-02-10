import 'package:app/core/engine_result.dart';

class RuntimeError extends Error {
  final ErrorType type;
  final String message;
  final int? position;
  final String? hint;
  final String? operation;
  final Object? cause;

  RuntimeError({
    required this.message,
    this.type = ErrorType.runtime,
    this.position,
    this.hint,
    this.operation,
    this.cause,
  });

  EngineError toEngineError() {
    final opPrefix = operation == null ? '' : '$operation: ';
    return EngineError(
      type,
      '$opPrefix$message',
      position: position,
      hint: hint,
    );
  }

  @override
  String toString() {
    final pos = position == null ? '' : ' at position $position';
    final op = operation == null ? '' : ' [$operation]';
    return 'Runtime Error$op: $message$pos';
  }
}
