import 'package:app/core/engine/binder/binder.dart';
import 'package:app/core/engine/evaluator/evaluator.dart';
import 'package:app/core/engine/evaluator/runtime_errors.dart';
import 'package:app/core/engine/parser/parser.dart';
import 'package:app/core/engine/parser/tokenizer.dart';
import 'package:app/core/engine_result.dart';
import 'package:app/core/eval_context.dart';
import 'package:app/core/eval_types.dart';
import 'package:app/services/logging_service.dart';

/// The public API for the calculation engine.
///
/// The UI should interact ONLY with this class. It manages:
/// 1. The persistent state (variables 'A', 'B', 'Ans', etc.)
/// 2. Global settings (Angle Mode, Precision)
/// 3. The execution pipeline (Tokenizer -> Parser -> Binder -> Evaluator)
class EvaluationEngine {
  /// Configuration for the engine (RAD/DEG, precision, etc.)

  // Persistent subsystems
  late final Binder _binder;
  late final Evaluator _evaluator;
  final LoggerService logger = LoggerService();

  EvaluationEngine() {
    _binder = Binder();
    _evaluator = Evaluator();
  }

  /// The main entry point for calculating a result.
  ///
  /// [input] is the raw string from the text field.
  EngineResult evaluate(String input, EvalContext context) {
    if (input.trim().isEmpty) {
      return EngineSuccess(NumberValue(0), context);
    }

    logger.debug('Evaluating expression: $input');

    try {
      // -----------------------------------------------------------------------
      // STEP 1: TOKENIZATION
      // Convert raw text into a stream of meaningful tokens
      // -----------------------------------------------------------------------
      final tokenizer = Tokenizer(input);
      final tokens = tokenizer.tokenize();

      logger.trace('Tokens: $tokens');
      // -----------------------------------------------------------------------
      // STEP 2: PARSING
      // Organize tokens into a structural tree (AST)
      // -----------------------------------------------------------------------
      final parser = Parser(tokens);
      final ast = parser.parse();

      logger.trace('AST: $ast');
      // -----------------------------------------------------------------------
      // STEP 3: BINDING (Semantic Analysis)
      // verify variable names, check types, link symbols to the Registry
      // -----------------------------------------------------------------------
      final boundProgram = _binder.bind(ast);

      logger.trace('Bound AST: $boundProgram');
      // Check for semantic errors (e.g., "Unknown variable 'x'")
      if (_binder.diagnostics.isNotEmpty) {
        final diagnostic = _binder.diagnostics.first;
        logger.warn('Binding diagnostic: ${diagnostic.toString()}');
        return EngineError(
          diagnostic.type,
          diagnostic.message,
          position: diagnostic.position,
          hint: diagnostic.hint,
        );
      }

      // -----------------------------------------------------------------------
      // STEP 4: EVALUATION
      // Execute the bound tree to get a final value
      // -----------------------------------------------------------------------
      final value = _evaluator.evaluate(boundProgram, context);
      logger.debug('Evaluation result: ${value.toDisplayString()}');

      // -----------------------------------------------------------------------
      // STEP 5: STATE UPDATE
      // Update 'Ans' variable for the next calculation
      // -----------------------------------------------------------------------
      _evaluator.setVariable('Ans', value);

      return EngineSuccess(value, context);
    } on EngineError catch (e) {
      logger.warn('Engine error: ${e.toString()}');
      return e;
    } on RuntimeError catch (e) {
      logger.warn('Runtime error: ${e.toString()}');
      return e.toEngineError();
    } catch (e, st) {
      logger.error('Unexpected engine failure', e, st);
      return EngineError(
        ErrorType.unknown,
        'Unexpected evaluation failure',
        hint: 'Please check the expression and try again.',
      );
    }
  }

  /// Manually set a variable (e.g., storing a value in memory 'A')
  void setVariable(String name, Value value) {
    // We update both Binder (so it knows the name exists)
    // and Evaluator (so it knows the value)
    _binder.defineVariable(name, value.type());
    _evaluator.setVariable(name, value);
  }

  /// Get the current value of a variable (e.g., for displaying memory)
  Value? getVariable(String name) {
    return _evaluator.getVariable(name);
  }

  /// Clear all user-defined variables (keeps 'Ans' and system constants)
  void clearVariables() {
    _evaluator.clearUserVariables();
    // Note: Binder might need a reset if we support deleting vars,
    // but for a calculator, types usually persist or we just re-bind.
  }
}
