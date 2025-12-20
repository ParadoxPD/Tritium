class CustomFunction {
  final String name;
  final List<String> parameters;
  final String formula;

  CustomFunction({
    required this.name,
    required this.parameters,
    required this.formula,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'parameters': parameters, 'formula': formula};
  }

  factory CustomFunction.fromJson(Map<String, dynamic> json) {
    return CustomFunction(
      name: json['name'],
      parameters: List<String>.from(json['parameters']),
      formula: json['formula'],
    );
  }
}
