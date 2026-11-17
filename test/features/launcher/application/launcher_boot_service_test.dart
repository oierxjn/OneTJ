import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/launcher/application/launcher_boot_service.dart';
import 'package:onetj/models/token_data.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/theme_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/hive_storage_service.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';
import 'package:onetj/services/webview_environment_service.dart';

/// 尽力删除临时目录。
///
/// 全局 [AppFileLogSink] 会向 `getApplicationSupportDirectory()/logs` 异步写日志，
/// 而该目录被本测试的 path_provider 桩指向同一个临时目录，删除时可能仍在写入，
/// 故这里重试若干次；失败不视为测试失败。
Future<void> _deleteTempDirBestEffort(Directory dir) async {
  for (int attempt = 0; attempt < 5; attempt += 1) {
    try {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      return;
    } on FileSystemException {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}

TokenData _buildToken({
  required int accessTokenExpiresIn,
  required int refreshTokenExpiresIn,
}) {
  return TokenData(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    scope: 'scope',
    idToken: 'id-token',
    sessionState: 'session-state',
    accessTokenExpiresIn: accessTokenExpiresIn,
    refreshTokenExpiresIn: refreshTokenExpiresIn,
    issuedAt: DateTime.now(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late TokenRepository tokenRepository;
  late ThemeChangeNotifier themeNotifier;

  LauncherBootService buildService({AuthHttpPost? httpPost}) {
    return LauncherBootService(
      hiveStorageService: HiveStorageService(),
      themeChangeNotifier: themeNotifier,
      webViewEnvironmentService: WebViewEnvironmentService(),
      settingsRepository: SettingsRepository(
        storage: InMemorySettingsStorage(),
      ),
      tokenRepository: tokenRepository,
      authTokenProvider: AuthTokenProvider(
        repository: tokenRepository,
        httpPost: httpPost,
      ),
    );
  }

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('launcher_boot_service_');
    LaunchWallpaperFileService.debugResetCache();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return tempDir.path;
      }
      return null;
    });
    tokenRepository = TokenRepository(storage: InMemoryTokenStorage());
    themeNotifier = ThemeChangeNotifier(
      repository: ThemeRepository(storage: InMemoryThemeStorage()),
    );
  });

  tearDown(() async {
    themeNotifier.dispose();
    LaunchWallpaperFileService.debugResetCache();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await _deleteTempDirBestEffort(tempDir);
  });

  group('LauncherBootService.run 初始会话状态', () {
    test('无令牌时判定为游客态', () async {
      final AuthStatus status = await buildService().run();

      expect(status, AuthStatus.guest);
    });

    test('令牌有效时判定为已登录', () async {
      await tokenRepository.saveToken(
        _buildToken(
          accessTokenExpiresIn: 3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      final AuthStatus status = await buildService().run();

      expect(status, AuthStatus.authenticated);
    });

    test('令牌已过期时判定为失效态（缓存保留）', () async {
      await tokenRepository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: -7200,
        ),
      );

      final AuthStatus status = await buildService().run();

      expect(status, AuthStatus.expired);
    });

    test('离线冷启动（refresh 仍有效）乐观判已登录，不误报失效', () async {
      // access 已过期、refresh 仍有效：启动会尝试联网刷新，离线时抛网络异常。
      await tokenRepository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      final AuthStatus status = await buildService(
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async =>
            throw NetworkException(message: 'offline'),
      ).run();

      expect(status, AuthStatus.authenticated);
    });

    test('刷新瞬时错误（5xx）不判失效，乐观判已登录', () async {
      await tokenRepository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      final AuthStatus status = await buildService(
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async =>
            http.Response('{}', 500),
      ).run();

      expect(status, AuthStatus.authenticated);
    });

    test('刷新被服务端 401 拒绝时判定为失效态', () async {
      await tokenRepository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      final AuthStatus status = await buildService(
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async =>
            http.Response('{}', 401),
      ).run();

      expect(status, AuthStatus.expired);
    });

    test('刷新被 HTTP 200 包装的 invalid_grant 拒绝时判定为失效态', () async {
      await tokenRepository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      final AuthStatus status = await buildService(
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async =>
            http.Response(
          '{"error_error":{"http_status_code":400,'
          '"http_body":"{\\"error\\":\\"invalid_grant\\",'
          '\\"error_description\\":\\"Session not active\\"}"}}',
          200,
        ),
      ).run();

      expect(status, AuthStatus.expired);
    });

    test('刷新被 HTTP 200 包装的 5xx 瞬时错误仍乐观判已登录', () async {
      await tokenRepository.saveToken(
        _buildToken(
          accessTokenExpiresIn: -3600,
          refreshTokenExpiresIn: 7200,
        ),
      );

      final AuthStatus status = await buildService(
        httpPost: (
          Uri uri, {
          Map<String, String>? headers,
          Object? body,
          Encoding? encoding,
          String loggerName = 'Http',
        }) async =>
            http.Response(
          '{"error_error":{"http_status_code":502,"http_body":"Bad Gateway"}}',
          200,
        ),
      ).run();

      expect(status, AuthStatus.authenticated);
    });
  });

  test('壁纸解析完成后回调恰好触发一次', () async {
    int callbackCount = 0;

    await buildService().run(
      onWallpaperResolved: (_) => callbackCount += 1,
    );

    expect(callbackCount, 1);
  });
}
