import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/function_service.dart';
import 'package:app/models/custom_function.dart';
import 'package:app/repositories/function_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late FunctionService service;

  setUp(() {
    service = FunctionService(FunctionRepository());
  });

  test('function registration', () {
    service.setFunctions([
      CustomFunction(name: 'f', parameters: ['x'], formula: 'x+1'),
    ]);

    expect(service.functions.containsKey('f'), true);
  });
}
