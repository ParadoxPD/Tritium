import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/eval_types.dart';

abstract class LibraryModule {
  Map<String, NativeFunction> get functions;
  Map<String, Value> get constants;
}
