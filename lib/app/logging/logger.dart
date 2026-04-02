import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:onetj/app/logging/file_log_sink.dart';
import 'package:onetj/app/logging/log_buffer.dart';
import 'package:onetj/app/logging/log_entry.dart';
import 'package:onetj/app/logging/log_file_info.dart';
import 'package:onetj/app/logging/log_formatter.dart';
import 'package:onetj/app/logging/log_level.dart';

class AppLogger {
  AppLogger._();

  static const int _defaultBufferCapacity = 500;
  static AppLogBuffer _buffer = AppLogBuffer(capacity: _defaultBufferCapacity);
  static final AppFileLogSink _fileSink = AppFileLogSink.instance;
  static bool _initialized = false;

  static void init({
    required bool verbose,
    int bufferCapacity = _defaultBufferCapacity,
  }) {
    if (_initialized) {
      return;
    }
    _buffer = AppLogBuffer(capacity: bufferCapacity);
    unawaited(_fileSink.init());
    Logger.root.level = verbose ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen(_handleRootLogRecord);
    _initialized = true;
    info(
      'AppLogger initialized',
      loggerName: 'AppLogger',
      context: <String, Object?>{
        'verbose': verbose,
        'bufferCapacity': bufferCapacity,
      },
    );
  }

  static List<AppLogEntry> recent({int limit = 100}) =>
      _buffer.recent(limit: limit);

  static Future<String?> currentLogFilePath() async {
    return _fileSink.currentLogFilePath();
  }

  static Future<List<AppLogFileInfo>> listLogFiles() async {
    return _fileSink.listLogFiles();
  }

  static Future<String> readLogFile(AppLogFileInfo fileInfo) async {
    return _fileSink.readLogFile(fileInfo);
  }

  static void debug(
    String message, {
    String loggerName = 'App',
    String? code,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    _append(
      level: AppLogLevel.debug,
      loggerName: loggerName,
      message: message,
      code: code,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static void info(
    String message, {
    String loggerName = 'App',
    String? code,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    _append(
      level: AppLogLevel.info,
      loggerName: loggerName,
      message: message,
      code: code,
      context: context,
    );
  }

  static void warning(
    String message, {
    String loggerName = 'App',
    String? code,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    _append(
      level: AppLogLevel.warning,
      loggerName: loggerName,
      message: message,
      code: code,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static void error(
    String message, {
    String loggerName = 'App',
    String? code,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    _append(
      level: AppLogLevel.error,
      loggerName: loggerName,
      message: message,
      code: code,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static void exception(
    Object error,
    StackTrace stackTrace, {
    String loggerName = 'App',
    String? code,
    String message = 'Unhandled exception',
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    _append(
      level: AppLogLevel.error,
      loggerName: loggerName,
      message: message,
      code: code,
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }

  static void logExceptionCreated({
    required String code,
    required String message,
    Object? cause,
  }) {
    _append(
      level: AppLogLevel.warning,
      loggerName: 'Exception',
      message: message,
      code: code,
      error: cause,
      context: const <String, Object?>{'phase': 'created'},
    );
  }

  static void logUiAction({
    required String feature,
    required String action,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    info(
      'UI action',
      loggerName: feature,
      context: <String, Object?>{
        'action': action,
        ...context,
      },
    );
  }

  static void logNavigation({
    required String from,
    required String to,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    info(
      'Navigation event',
      loggerName: 'Navigation',
      context: <String, Object?>{
        'from': from,
        'to': to,
        ...context,
      },
    );
  }

  static void logNetworkRequest({
    required String method,
    required Uri uri,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    info(
      'Network request',
      loggerName: 'Network',
      context: <String, Object?>{
        'method': method,
        'path': uri.path,
        ...context,
      },
    );
  }

  static void logNetworkResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required int elapsedMs,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    info(
      'Network response',
      loggerName: 'Network',
      context: <String, Object?>{
        'method': method,
        'path': uri.path,
        'statusCode': statusCode,
        'elapsedMs': elapsedMs,
        ...context,
      },
    );
  }

  static void _append({
    required AppLogLevel level,
    required String loggerName,
    required String message,
    String? code,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const <String, Object?>{},
  }) {
    if (!_initialized) {
      init(verbose: kDebugMode);
    }
    final Map<String, Object?> safeContext = _sanitizeContext(context);
    final AppLogEntry entry = AppLogEntry(
      time: DateTime.now(),
      level: level,
      loggerName: loggerName,
      message: message,
      code: code,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
      context: safeContext,
    );
    _buffer.add(entry);
    final String plainText = AppLogFormatter.toPlainText(entry);
    unawaited(_fileSink.writeLine(plainText));
    if (entry.stackTrace != null && entry.stackTrace!.isNotEmpty) {
      unawaited(_fileSink.writeLine(entry.stackTrace!));
    }
    if (kDebugMode) {
      debugPrint('[ONETJ] $plainText');
      if (entry.stackTrace != null && entry.stackTrace!.isNotEmpty) {
        debugPrint(entry.stackTrace);
      }
    }
  }

  // 对日志记录中的上下文进行脱敏处理
  static Map<String, Object?> _sanitizeContext(Map<String, Object?> context) {
    if (context.isEmpty) {
      return const <String, Object?>{};
    }
    final Map<String, Object?> safe = <String, Object?>{};
    for (final MapEntry<String, Object?> pair in context.entries) {
      if (_isSensitiveKey(pair.key)) {
        safe[pair.key] = '***';
      } else {
        safe[pair.key] = pair.value;
      }
    }
    return safe;
  }

  // 检查日志记录中的键是否包含敏感信息
  static bool _isSensitiveKey(String key) {
    final String lower = key.toLowerCase();
    return lower.contains('token') ||
        lower.contains('authorization') ||
        lower.contains('cookie') ||
        lower.contains('password');
  }

  static void _handleRootLogRecord(LogRecord record) {
    _append(
      level: _fromLoggingLevel(record.level),
      loggerName: record.loggerName,
      message: record.message,
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }

  // 将Dart日志级别转换为应用日志级别
  static AppLogLevel _fromLoggingLevel(Level level) {
    if (level >= Level.SEVERE) {
      return AppLogLevel.error;
    }
    if (level >= Level.WARNING) {
      return AppLogLevel.warning;
    }
    if (level >= Level.INFO) {
      return AppLogLevel.info;
    }
    return AppLogLevel.debug;
  }
}
