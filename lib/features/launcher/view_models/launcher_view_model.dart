import 'dart:async';

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
  Stream<UiEvent> get events => _eventController.stream;

  /// 进行初始化任务和跳转路由
  Future<void> initialize() async {
    // 同步任务
    AppLoggingBootstrap.ensureInitialized();

    AppLogger.info(
      'Launcher initialization started',
      loggerName: 'LauncherViewModel',
    );

    final List<Object?> results = await Future.wait([
      // 异步任务
      _initialize(),
      // 启动延迟
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);

    final String route = results.first as String;
    AppLogger.logNavigation(
      from: RoutePaths.launcher,
      to: route,
      context: const <String, Object?>{'phase': 'launcher_initialize'},
    );
    _eventController.add(NavigateEvent(route));
  }

  Future<String> _initialize() async {
    await _hiveStorageService.initializeHive();
    await Future.wait([
      WebViewEnvironmentService.instance.initialize(),
      SettingsRepository.getInstance().getSettings(
        refreshFromStorage: true,
      ),
    ]);
    final String route = await _resolveInitialRoute();
    return route;
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
