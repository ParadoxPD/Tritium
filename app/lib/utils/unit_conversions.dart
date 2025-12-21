class UnitConversions {
  static const List<String> categories = [
    'Length',
    'Weight',
    'Temperature',
    'Area',
    'Volume',
  ];

  // Multiplicative conversions only (NON-temperature)
  static final Map<String, Map<String, double>> _factors = {
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
    if (category == 'Temperature') {
      return const ['celsius', 'fahrenheit', 'kelvin'];
    }

    final units = _factors[category];
    if (units == null) {
      throw Exception('Unknown category: $category');
    }
    return units.keys.toList();
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

    final cat = _factors[category];
    if (cat == null) {
      throw Exception('Unknown category: $category');
    }

    final fromFactor = cat[fromUnit];
    final toFactor = cat[toUnit];

    if (fromFactor == null || toFactor == null) {
      throw Exception('Invalid unit for $category');
    }

    // Convert via base unit
    return value * (toFactor / fromFactor);
  }

  static double _convertTemperature(double value, String from, String to) {
    double celsius;

    switch (from) {
      case 'celsius':
        celsius = value;
        break;
      case 'fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'kelvin':
        celsius = value - 273.15;
        break;
      default:
        throw Exception('Invalid temperature unit');
    }

    switch (to) {
      case 'celsius':
        return celsius;
      case 'fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'kelvin':
        return celsius + 273.15;
      default:
        throw Exception('Invalid temperature unit');
    }
  }
}
