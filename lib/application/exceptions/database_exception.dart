class DatabaseException implements Exception {
  DatabaseException({this.message, this.exception});

  final String? message;
  final Exception? exception;

  @override
  String toString() =>
      'DatabaseException{message: $message, exception: $exception}';
}
