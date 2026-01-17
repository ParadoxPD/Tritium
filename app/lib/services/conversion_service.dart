import 'package:app/models/unit_models.dart';
import 'package:app/services/unit_data.dart';
import 'package:flutter/material.dart';

class ConversionService extends ChangeNotifier {
  CategoryDefinition _currentCategory = UnitData.categories.first;
  UnitDefinition? _fromUnit;
  UnitDefinition? _toUnit;

  String _input = "";
  String _output = "";

  ConversionService() {
    _fromUnit = _currentCategory.units.first;
    _toUnit = _currentCategory.units.length > 1
        ? _currentCategory.units[1]
        : _currentCategory.units.first;
  }

  // ================= GETTERS =================
  CategoryDefinition get currentCategory => _currentCategory;
  UnitDefinition? get fromUnit => _fromUnit;
  UnitDefinition? get toUnit => _toUnit;
  String get input => _input;
  String get output => _output;

  // ================= CATEGORY =================
  void setCategory(CategoryDefinition cat) {
    _currentCategory = cat;

    _fromUnit = cat.units.first;
    _toUnit = cat.units.length > 1 ? cat.units[1] : cat.units.first;

    _input = "";
    _output = "";
    FocusManager.instance.primaryFocus?.unfocus();

    notifyListeners();
  }

  // ================= UNITS =================
  void updateUnits({UnitDefinition? from, UnitDefinition? to}) {
    if (from != null) _fromUnit = from;
    if (to != null) _toUnit = to;

    // Recalculate if input exists
    if (_input.isNotEmpty) {
      convert(_input);
      return;
    }

    notifyListeners();
  }

  // ================= CONVERSION =================
  void convert(String input) {
    _input = input;

    if (input.isEmpty || _fromUnit == null || _toUnit == null) {
      _output = "";
      notifyListeners();
      return;
    }

    try {
      final value = double.parse(input);

      // TO BASE
      final baseValue = _fromUnit!.toBase != null
          ? _fromUnit!.toBase!(value)
          : value / _fromUnit!.factor;

      // FROM BASE
      final result = _toUnit!.fromBase != null
          ? _toUnit!.fromBase!(baseValue)
          : baseValue * _toUnit!.factor;

      _output = _smartFormat(result);
    } catch (_) {
      _output = "Error";
    }

    notifyListeners();
  }

  // ================= SWAP =================
  void swap() {
    if (_fromUnit == null || _toUnit == null) return;

    final tmpUnit = _fromUnit;
    _fromUnit = _toUnit;
    _toUnit = tmpUnit;

    // Swap values (only if valid)
    if (_output.isNotEmpty) {
      _input = _output;
      _output = "";
      convert(_input);
    }

    notifyListeners();
  }

  // ================= FORMAT =================
  String _smartFormat(double value) {
    if (value == 0) return "0";
    if (value.abs() < 0.001 || value.abs() > 1e7) {
      return value.toStringAsExponential(4);
    }
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
