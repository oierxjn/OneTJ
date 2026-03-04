import 'package:onetj/app/logging/logger.dart';

class AppException implements Exception {
  final String code;
  final String message;
  final Object? cause;

  AppException(this.code, this.message, {this.cause}) {
    try {
      AppLogger.logExceptionCreated(
        code: code,
        message: message,
        cause: cause,
      );
    } catch (_) {
      // Keep exception construction side-effect safe.
    }
  }

  @override
  String toString() => '$code: $message\n cause: ${cause?.toString()}';
}

class AuthStateMismatchException extends AppException {
  static const String errorCode = 'AUTH_STATE_MISMATCH';
  AuthStateMismatchException()
      : super(errorCode, 'Auth state mismatch, possible network attack');
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
  JSONResolveException({required String message, Object? cause})
      : super(_code, message, cause: cause);
}

class SettingsResolveException extends AppException {
  static const String _code = 'SETTINGS_RESOLVE_ERROR';
  SettingsResolveException({required String message, Object? cause})
      : super(_code, message, cause: cause);
}

class SettingsValidationException extends AppException {
  static const String errorCode = 'SETTINGS_VALIDATION_ERROR';
  static const String maxWeekInvalidFormat = 'SETTINGS_MAX_WEEK_INVALID_FORMAT';
  static const String maxWeekOutOfRange = 'SETTINGS_MAX_WEEK_OUT_OF_RANGE';
  static const String timeSlotEmpty = 'SETTINGS_TIME_SLOT_EMPTY';
  static const String timeSlotStartOutOfRange =
      'SETTINGS_TIME_SLOT_START_OUT_OF_RANGE';
  static const String timeSlotEndOutOfRange =
      'SETTINGS_TIME_SLOT_END_OUT_OF_RANGE';
  static const String timeSlotRangeInvalid = 'SETTINGS_TIME_SLOT_RANGE_INVALID';
  static const String timeSlotOrderInvalid = 'SETTINGS_TIME_SLOT_ORDER_INVALID';
  static const String timeSlotOverlap = 'SETTINGS_TIME_SLOT_OVERLAP';
  static const String timeSlotStartMinutesItemOutOfRange =
      'SETTINGS_TIME_SLOT_START_MINUTES_ITEM_OUT_OF_RANGE';
  static const String timeSlotStartMinutesNotIncreasing =
      'SETTINGS_TIME_SLOT_START_MINUTES_NOT_INCREASING';
  static const String dashboardUpcomingCountOutOfRange =
      'SETTINGS_DASHBOARD_UPCOMING_COUNT_OUT_OF_RANGE';
  static const String dashboardUpcomingCountInvalidFormat =
      'SETTINGS_DASHBOARD_UPCOMING_COUNT_INVALID_FORMAT';

  SettingsValidationException({
    required String code,
    required String message,
    Object? cause,
  }) : super(code, message, cause: cause);
}
