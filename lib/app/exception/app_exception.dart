class AppException implements Exception {
  final String code;
  final String message;
  final Object? cause;

  AppException(this.code, this.message, {this.cause});

  @override
  String toString() => '$code: $message';
}

class AuthStateMismatchException extends AppException {
  static const String _code = 'AUTH_STATE_MISMATCH';
  AuthStateMismatchException() : super(_code, 'Auth state mismatch, possible network attack');
}

class NetworkException extends AppException {
  static const String _code = 'NETWORK_ERROR';
  final int? statusCode;
  final Uri? uri;
  final String? responseBody;

  NetworkException({
    required String message,
    this.statusCode,
    this.uri,
    this.responseBody,
    Object? cause,
  }) : super(_code, message, cause: cause);

  factory NetworkException.http({
    required int statusCode,
    required Uri uri,
    String? responseBody,
  }) {
    return NetworkException(
      message: 'Request failed',
      statusCode: statusCode,
      uri: uri,
      responseBody: responseBody,
    );
  }
}
class JSONResolveException extends AppException {
  static const String _code = 'JSON_RESOLVE_ERROR';
  JSONResolveException({required String message, Object? cause}) : super(_code, message, cause: cause);
}