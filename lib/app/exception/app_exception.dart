class AppException implements Exception {
  final String code;
  final String message;
  final Object? cause;

  AppException(this.code, this.message, {this.cause});

  @override
  String toString() => '$code: $message';
}

class AuthStateMismatchException extends AppException {
  AuthStateMismatchException() : super('AUTH_STATE_MISMATCH', '验证状态返回错误，可能是网络遭受攻击');
}