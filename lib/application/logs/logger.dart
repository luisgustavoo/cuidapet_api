import 'package:logger/logger.dart' as log;

import 'i_logger.dart';

class Logger implements ILogger {
  final _logger = log.Logger();

  @override
  void debug(Object message, [Object? error, StackTrace? stackTrace]) =>
      _logger.d(message, error, stackTrace);

  @override
  void error(Object message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error, stackTrace);

  @override
  void info(Object message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error, stackTrace);

  @override
  void warning(Object message, [Object? error, StackTrace? stackTrace]) =>
      _logger.i(message, error, stackTrace);
}
