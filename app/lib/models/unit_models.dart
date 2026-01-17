import 'package:flutter/material.dart';

class UnitDefinition {
  final String name;
  final String symbol;
  final double factor; // Value relative to the base unit
  final double Function(double)? toBase; // Custom logic for non-linear
  final double Function(double)? fromBase;

  const UnitDefinition({
    required this.name,
    required this.symbol,
    this.factor = 1.0,
    this.toBase,
    this.fromBase,
  });
}

class CategoryDefinition {
  final String name;
  final IconData icon;
  final String domain; // e.g., "Physics", "Chemistry"
  final List<UnitDefinition> units;

  const CategoryDefinition({
    required this.name,
    required this.icon,
    required this.domain,
    required this.units,
  });
}
