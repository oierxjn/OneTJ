import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/data/code2token.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/tongji.dart';

class LauncherViewModel extends BaseViewModel {
  LauncherViewModel() : _eventController = StreamController<UiEvent>.broadcast();

  static final Logger _logger = Logger('LauncherViewModel');

  final StreamController<UiEvent> _eventController;
  Stream<UiEvent> get events => _eventController.stream;

  /// 进行初始化任务和跳转路由
  Future<void> initialize() async {
    // 同步任务
    _initializeLogging();
    final List<Object?> results = await Future.wait([
      // 异步任务
      _initialize(),
      // 启动延迟
      Future.delayed(const Duration(milliseconds: 1200)),
    ]);
    final String route = results.first as String;
    _eventController.add(NavigateEvent(route));
  }

  Future<String> _initialize() async {
    await Hive.initFlutter();
    final String route = await _resolveInitialRoute();
    return route;
  }

  Future<String> _resolveInitialRoute() async {
    final TokenRepository repo = TokenRepository.getInstance();
    final TokenData? token = await repo.getToken(refreshFromStorage: true);
    if (token != null && !token.isAccessTokenExpired(skew: const Duration(seconds: 30))) {
      return '/home';
    }
    if (token != null && !token.isRefreshTokenExpired(skew: const Duration(seconds: 30))) {
      try {
        final TongjiApi api = TongjiApi();
        final Code2TokenData refreshed = await api.refreshToken(token.refreshToken);
        await repo.saveFromCode2Token(refreshed);
        return '/home';
      } catch (error, stackTrace) {
        _logger.warning('Failed to refresh token', error, stackTrace);
      }
    }
    return '/login';
  }

  void _initializeLogging() {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.time} [${record.level.name}] ${record.loggerName}: [ONETJ] ${record.message}');
    });
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
