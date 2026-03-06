import 'package:onetj/app/exception/app_exception.dart';

class DeveloperDebugEndpointException extends AppException {
  static const String invalidFormat = 'DEVELOPER_DEBUG_ENDPOINT_INVALID_FORMAT';
  static const String invalidScheme = 'DEVELOPER_DEBUG_ENDPOINT_INVALID_SCHEME';

  DeveloperDebugEndpointException({
    required String code,
    required String message,
    Object? cause,
  }) : super(code, message, cause: cause);
}
