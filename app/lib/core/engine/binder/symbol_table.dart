// ============================================================================
// FILE: core/engine/binder/symbol_table.dart
// Symbol resolution and type checking
// ============================================================================

class Symbol {
  final String name;
  final ValueType type;
  final bool isConstant;

  const Symbol(this.name, this.type, {this.isConstant = false});
}

enum ValueType {
  number,
  complex,
  matrix,
  vector,
  fraction,
  boolean,
  string,
  record,
  list,
  function,
  any,
  unknown,
}

class SymbolTable {
  final SymbolTable? parent;
  final Map<String, Symbol> _symbols = {};

  SymbolTable([this.parent]);

  void define(String name, ValueType type, {bool isConstant = false}) {
    _symbols[name] = Symbol(name, type, isConstant: isConstant);
  }

  Symbol? lookup(String name) {
    return _symbols[name] ?? parent?.lookup(name);
  }

  bool isDefined(String name) => lookup(name) != null;

  SymbolTable createChild() => SymbolTable(this);
}
