import 'dart:async';
import 'dart:io';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/logging/logging_bootstrap.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/hive_storage_service.dart';
import 'package:onetj/services/tongji.dart';
import 'package:onetj/services/webview_environment_service.dart';

class LauncherViewModel extends BaseViewModel {
  LauncherViewModel()
      : _eventController = StreamController<UiEvent>.broadcast(),
        _hiveStorageService = HiveStorageService();

  final StreamController<UiEvent> _eventController;
  final HiveStorageService _hiveStorageService;
  String? _wallpaperFilePath;

  Stream<UiEvent> get events => _eventController.stream;
  String? get wallpaperFilePath => _wallpaperFilePath;
  bool get useDefaultWallpaper => _wallpaperFilePath == null;

  /// 进行初始化任务和跳转路由
  Future<void> initialize() async {
    // 同步任务
    AppLoggingBootstrap.ensureInitialized();

    AppLogger.info(
      'Launcher initialization started',
      loggerName: 'LauncherViewModel',
    );

    final Future<String> initFuture = _initialize();
    final Future<void> delayFuture = Future.delayed(
      const Duration(milliseconds: 1200),
    );

    final String route = await initFuture;
    await delayFuture;

    AppLogger.logNavigation(
      from: RoutePaths.launcher,
      to: route,
      context: const <String, Object?>{'phase': 'launcher_initialize'},
    );
    _eventController.add(NavigateEvent(route));
  }

  /// 根据初始化状况返回初始路由
  Future<String> _initialize() async {
    await _hiveStorageService.initializeHive();
    final Future<void> webViewInitFuture =
        WebViewEnvironmentService.instance.initialize();
    final Future<SettingsData> settingsFuture =
        SettingsRepository.getInstance().getSettings(
      refreshFromStorage: true,
    );

    final SettingsData settings = await settingsFuture;
    final String? wallpaperFilePath = await _resolveWallpaperFilePath(settings);
    _updateWallpaperFilePath(wallpaperFilePath);
    await webViewInitFuture;
    final String route = await _resolveInitialRoute();
    return route;
  }

  Future<String?> _resolveWallpaperFilePath(SettingsData settings) async {
    final String? path = settings.launchWallpaperPath;
    if (path == null || path.isEmpty) {
      AppLogger.info(
        'Launch wallpaper fallback to default by empty custom path',
        loggerName: 'LauncherViewModel',
      );
      return null;
    }
    if (!await File(path).exists()) {
      AppLogger.warning(
        'Launch wallpaper fallback to default by missing custom file',
        loggerName: 'LauncherViewModel',
        context: <String, Object?>{'path': path},
      );
      return null;
    }
    AppLogger.info(
      'Launch wallpaper resolved to custom file',
      loggerName: 'LauncherViewModel',
      context: <String, Object?>{'path': path},
    );
    return path;
  }

  void _updateWallpaperFilePath(String? path) {
    if (_wallpaperFilePath == path) {
      return;
    }
    _wallpaperFilePath = path;
    notifyListeners();
  }

  /// 通过判断 token 状态来确定初始路由
  ///
  /// 如果 token 有效，则返回 [RoutePaths.home]，否则返回 [RoutePaths.login]。
  Future<String> _resolveInitialRoute() async {
    final TokenRepository repo = TokenRepository.getInstance();
    final TokenData? token = await repo.getToken(refreshFromStorage: true);

    if (token != null &&
        !token.isAccessTokenExpired(skew: const Duration(seconds: 30))) {
      AppLogger.info(
        'Resolved route by valid access token',
        loggerName: 'LauncherViewModel',
        context: const <String, Object?>{'route': RoutePaths.home},
      );
      return RoutePaths.home;
    }

    if (token != null &&
        !token.isRefreshTokenExpired(skew: const Duration(seconds: 30))) {
      try {
        final TongjiApi api = TongjiApi();
        final Code2TokenData refreshed =
            await api.refreshToken(token.refreshToken);
        await repo.saveFromCode2Token(refreshed);
        AppLogger.info(
          'Resolved route by refresh token',
          loggerName: 'LauncherViewModel',
          context: const <String, Object?>{'route': RoutePaths.home},
        );
        return RoutePaths.home;
      } catch (error, stackTrace) {
        AppLogger.warning(
          'Failed to refresh token during launch',
          loggerName: 'LauncherViewModel',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    AppLogger.info(
      'Resolved route to login',
      loggerName: 'LauncherViewModel',
      context: const <String, Object?>{'route': RoutePaths.login},
    );
    return RoutePaths.login;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
