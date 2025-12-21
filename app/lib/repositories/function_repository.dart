import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_function.dart';

class FunctionRepository {
  static const _key = 'custom_functions';

  Future<void> save(List<CustomFunction> functions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = functions
        .map((f) => {'name': f.name, 'params': f.parameters, 'body': f.formula})
        .toList();

    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<CustomFunction>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List data = jsonDecode(raw);
    return data
        .map(
          (e) => CustomFunction(
            name: e['name'],
            parameters: List<String>.from(e['params']),
            formula: e['body'],
          ),
        )
        .toList();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
