import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:onetj/app/logging/logger.dart';

class WebViewEnvironmentService {
  WebViewEnvironmentService._();

  static final WebViewEnvironmentService instance =
      WebViewEnvironmentService._();

  WebViewEnvironment? _environment;
  bool _initialized = false;

  WebViewEnvironment? get environment => _environment;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    if (!Platform.isWindows) {
      return;
    }

    try {
      final Directory userDataDirectory = await _resolveUserDataDirectory();
      if (!await userDataDirectory.exists()) {
        await userDataDirectory.create(recursive: true);
      }
      _environment = await WebViewEnvironment.create(
        settings: WebViewEnvironmentSettings(
          userDataFolder: userDataDirectory.path,
        ),
      );
      AppLogger.info(
        'WebView environment initialized',
        loggerName: 'WebViewEnvironmentService',
        context: <String, Object?>{'userDataFolder': userDataDirectory.path},
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'WebView environment initialization failed, using default environment',
        loggerName: 'WebViewEnvironmentService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Directory> _resolveUserDataDirectory() async {
    final String? localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return Directory(path.join(localAppData, 'OneTJ', 'EBWebView'));
    }

    final Directory supportDirectory = await getApplicationSupportDirectory();
    return Directory(path.join(supportDirectory.path, 'EBWebView'));
  }
}
