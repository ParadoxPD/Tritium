// ============================================================================
// FILE: core/eval_context.dart
// Runtime context (variables, functions, settings)
// ============================================================================

import 'package:app/core/eval_types.dart';

enum AngleMode { radians, degrees }

enum BaseMode { decimal, binary, octal, hexadecimal }

enum DisplayMode { normal, engineering, scientific }

class EvalContext {
  final Map<String, Value> variables;
  final Map<String, FunctionDefinition> functions;
  final AngleMode angleMode;
  final BaseMode baseMode;
  final DisplayMode displayMode;
  final bool exactMode; // Use fractions when possible

  const EvalContext({
    this.variables = const {},
    this.functions = const {},
    this.angleMode = AngleMode.radians,
    this.baseMode = BaseMode.decimal,
    this.displayMode = DisplayMode.normal,
    this.exactMode = false,
  });

  EvalContext copyWith({
    Map<String, Value>? variables,
    Map<String, FunctionDefinition>? functions,
    AngleMode? angleMode,
    BaseMode? baseMode,
    DisplayMode? displayMode,
    bool? exactMode,
  }) {
    return EvalContext(
      variables: variables ?? this.variables,
      functions: functions ?? this.functions,
      angleMode: angleMode ?? this.angleMode,
      baseMode: baseMode ?? this.baseMode,
      displayMode: displayMode ?? this.displayMode,
      exactMode: exactMode ?? this.exactMode,
    );
  }
}

class FunctionDefinition {
  final List<String> parameters;
  final dynamic body; // Can be AST node or native function
  final bool isNative;

  const FunctionDefinition(this.parameters, this.body, {this.isNative = false});
}
