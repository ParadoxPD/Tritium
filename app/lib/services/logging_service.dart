import 'package:logger/logger.dart';

class LoggerService {
  final _logger = Logger(
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
    _logger.log(Level.info, message);
  }

  void warn(String message) {
    _logger.log(Level.warning, message);
  }

  void debug(String message) {
    _logger.log(Level.debug, message);
  }

  void trace(String message) {
    _logger.log(Level.trace, message);
  }
}
