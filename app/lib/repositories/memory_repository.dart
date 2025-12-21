import 'package:shared_preferences/shared_preferences.dart';

class MemoryRepository {
  static const _memKey = 'memory_value';
  static const _ansKey = 'ans_value';

  Future<void> saveMemory(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_memKey, value);
  }

  Future<double> loadMemory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_memKey) ?? 0.0;
  }

  Future<void> saveANS(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_ansKey, value);
  }

  Future<double?> loadANS() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_ansKey);
  }
}
