class AppException implements Exception {
  final String code;
  final String message;
  final Object? cause;

  AppException(this.code, this.message, {this.cause});

  @override
  String toString() => '$code: $message';
}

class AuthStateMismatchException extends AppException {
  AuthStateMismatchException() : super('AUTH_STATE_MISMATCH', 'Auth state mismatch, possible network attack');
}