import 'package:flutter/foundation.dart';

import 'package:onetj/app/logging/app_logger.dart';

class AppLoggingBootstrap {
  AppLoggingBootstrap._();

  static bool _initialized = false;
  static bool _initializing = false;

  static void ensureInitialized() {
    if (_initialized || _initializing) {
      return;
    }
    _initializing = true;
    try {
      AppLogger.init(verbose: kDebugMode);

      // 记录Flutter框架错误
      final FlutterExceptionHandler? previousFlutterErrorHandler =
          FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        AppLogger.exception(
          details.exception,
          details.stack ?? StackTrace.current,
          loggerName: 'FlutterError',
          message: 'Flutter framework error',
          context: <String, Object?>{
            'library': details.library ?? '',
            'context': details.context?.toDescription() ?? '',
          },
        );
        previousFlutterErrorHandler?.call(details);
      };

      // 记录平台适配器错误
      PlatformDispatcher.instance.onError =
          (Object error, StackTrace stackTrace) {
        AppLogger.exception(
          error,
          stackTrace,
          loggerName: 'PlatformDispatcher',
          message: 'Platform unhandled error',
        );
        return false;
      };

      _initialized = true;
      AppLogger.info(
        'Logging bootstrap initialized',
        loggerName: 'AppLoggingBootstrap',
      );
    } finally {
      _initializing = false;
    }
  }
}
