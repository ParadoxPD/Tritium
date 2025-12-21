import 'package:app/core/evaluator/eval_types.dart';

class EvalContext {
  final Map<String, double> variables;
  final Map<String, FunctionDef> functions;

  const EvalContext({this.variables = const {}, this.functions = const {}});
}
