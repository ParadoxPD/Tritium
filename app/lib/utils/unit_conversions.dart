class UnitConversions {
  static const List<String> categories = [
    'Length',
    'Weight',
    'Temperature',
    'Area',
    'Volume',
  ];

  static final Map<String, Map<String, double>> _conversions = {
    'Length': {
      'meter': 1.0,
      'kilometer': 0.001,
      'centimeter': 100.0,
      'mile': 0.000621371,
      'yard': 1.09361,
      'foot': 3.28084,
      'inch': 39.3701,
    },
    'Weight': {
      'kilogram': 1.0,
      'gram': 1000.0,
      'pound': 2.20462,
      'ounce': 35.274,
      'ton': 0.001,
    },
    'Temperature': {'celsius': 1.0, 'fahrenheit': 1.0, 'kelvin': 1.0},
    'Area': {
      'square_meter': 1.0,
      'square_kilometer': 1e-6,
      'square_mile': 3.861e-7,
      'acre': 0.000247105,
      'hectare': 0.0001,
    },
    'Volume': {
      'liter': 1.0,
      'milliliter': 1000.0,
      'gallon': 0.264172,
      'cubic_meter': 0.001,
    },
  };

  static List<String> getUnitsForCategory(String category) {
    return _conversions[category]!.keys.toList();
  }

  static double convert(
    double value,
    String category,
    String fromUnit,
    String toUnit,
  ) {
    if (category == 'Temperature') {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    final fromFactor = _conversions[category]![fromUnit]!;
    final toFactor = _conversions[category]![toUnit]!;
    return value * (toFactor / fromFactor);
  }

  static double _convertTemperature(double value, String from, String to) {
    double celsius;
    if (from == 'celsius') {
      celsius = value;
    } else if (from == 'fahrenheit') {
      celsius = (value - 32) * 5 / 9;
    } else {
      celsius = value - 273.15;
    }

    if (to == 'celsius') {
      return celsius;
    } else if (to == 'fahrenheit') {
      return celsius * 9 / 5 + 32;
    } else {
      return celsius + 273.15;
    }
  }
}
