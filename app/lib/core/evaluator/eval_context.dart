import 'package:app/core/evaluator/eval_types.dart';

// ===================== EVALUATION CONTEXT =====================

class EvalContext {
  final Map<String, double> variables;
  final Map<String, FunctionDef> functions;
  final Map<String, Matrix> matrices;
  final Map<String, Complex> complexVars;
  final BaseMode baseMode;
  final bool exactMode; // Use fractions when possible

  const EvalContext({
    this.variables = const {},
    this.functions = const {},
    this.matrices = const {},
    this.complexVars = const {},
    this.baseMode = BaseMode.decimal,
    this.exactMode = false,
  });

  EvalContext copyWith({
    Map<String, double>? variables,
    Map<String, FunctionDef>? functions,
    Map<String, Matrix>? matrices,
    Map<String, Complex>? complexVars,
    BaseMode? baseMode,
    bool? exactMode,
  }) {
    return EvalContext(
      variables: variables ?? this.variables,
      functions: functions ?? this.functions,
      matrices: matrices ?? this.matrices,
      complexVars: complexVars ?? this.complexVars,
      baseMode: baseMode ?? this.baseMode,
      exactMode: exactMode ?? this.exactMode,
    );
  }
}
