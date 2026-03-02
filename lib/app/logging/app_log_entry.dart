import 'package:onetj/app/logging/app_log_level.dart';

class AppLogEntry {
  const AppLogEntry({
    required this.time,
    required this.level,
    required this.loggerName,
    required this.message,
    this.code,
    this.error,
    this.stackTrace,
    this.context = const <String, Object?>{},
  });

  final DateTime time;
  final AppLogLevel level;
  final String loggerName;
  final String message;
  final String? code;
  final String? error;
  final String? stackTrace;
  final Map<String, Object?> context;
}
