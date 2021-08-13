import 'package:cuidapet_api/application/logs/i_logger.dart';
import 'package:logger/logger.dart' as log;

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
