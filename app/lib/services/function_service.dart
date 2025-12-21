import 'package:app/core/evaluator/eval_types.dart';
import 'package:app/repositories/function_repository.dart';

import '../models/custom_function.dart';

class FunctionService {
  final FunctionRepository _repo;
  final Map<String, FunctionDef> _functions = {};
  final List<CustomFunction> _raw = [];

  FunctionService(this._repo);
  List<CustomFunction> get currentFunctions => List.unmodifiable(_raw);

  Future<void> restore() async {
    final list = await _repo.load();
    setFunctions(list);
  }

  void setFunctions(List<CustomFunction> list) {
    _raw
      ..clear()
      ..addAll(list);

    _functions
      ..clear()
      ..addEntries(
        list.map((f) => MapEntry(f.name, FunctionDef(f.parameters, f.formula))),
      );

    _repo.save(list);
  }

  Map<String, FunctionDef> get functions => _functions;
}
