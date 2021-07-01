class UserNotFoundException implements Exception {
  UserNotFoundException({required this.message});

  final String? message;
}
