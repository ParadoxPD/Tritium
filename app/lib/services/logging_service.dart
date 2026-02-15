import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerService {
  LoggerService._();

  static final LoggerService _instance = LoggerService._();

  factory LoggerService() => _instance;

  bool enabled = !kReleaseMode;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      // Should each log print contain a timestamp
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void info(String message) {
    if (!enabled) return;
    _logger.log(Level.info, message);
  }

  void warn(String message) {
    if (!enabled) return;
    _logger.log(Level.warning, message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!enabled) return;
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void debug(String message) {
    if (!enabled) return;
    _logger.log(Level.debug, message);
  }

  void trace(String message) {
    if (!enabled) return;
    _logger.log(Level.trace, message);
  }
}
