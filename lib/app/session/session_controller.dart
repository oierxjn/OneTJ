import 'package:flutter/foundation.dart';

import 'package:onetj/app/logging/logger.dart';

/// 会话鉴权状态。
///
/// [unknown] 表示启动引导（Hive / 主题 / 令牌校验）与启动页最短展示时间
/// 尚未结束。守卫在 [unknown] 下不做任何跳转，避免初始位置抖动。
enum AuthStatus { unknown, authenticated, unauthenticated }

/// 应用级会话状态源。
///
/// 路由守卫必须在 `redirect` 中同步拿到「当前是否已登录」，而
/// [TokenRepository] 与 [AuthTokenProvider] 的判定都是异步的，因此这里把
/// 登录态收敛为一个可同步读取、且能被 `GoRouter` 作为 `refreshListenable`
/// 监听的状态：状态变化会触发守卫重新求值，用户无论停在哪一层页面，
/// 登录态失效时都会被整体替换到登录页。
///
/// 本类只负责保存状态，不含路由知识；「哪些路径需要登录」由路由守卫决定。
class SessionController extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _pendingLocation;
  String? _lastReason;

  AuthStatus get status => _status;

  /// 登录成功后要回跳的位置（如令牌中途失效时所在的页面）。仅驻留内存。
  String? get pendingLocation => _pendingLocation;

  /// 最近一次状态变化的原因，便于排查跳转时机。
  String? get lastReason => _lastReason;

  /// 启动引导完成后发布初始状态。
  ///
  /// 这是唯一能把状态移出 [AuthStatus.unknown] 的入口，从而保证启动页的
  /// 最短展示时间不会被令牌校验提前打断。
  void completeBoot(AuthStatus status) {
    if (status == AuthStatus.unknown) {
      return;
    }
    _transitionTo(status, reason: 'boot');
  }

  /// 登录成功、已取得有效令牌时调用。
  void markAuthenticated() {
    _transitionTo(AuthStatus.authenticated, reason: 'login');
  }

  /// 运行期发现令牌失效（刷新被拒或服务端 401）时调用。
  ///
  /// 处于 [AuthStatus.unknown] 时忽略：启动期的校验失败由
  /// [LauncherBootService] 自行决定初始状态，不应在启动页未结束时触发跳转。
  void markUnauthenticated({required String reason}) {
    if (_status == AuthStatus.unknown) {
      return;
    }
    _transitionTo(AuthStatus.unauthenticated, reason: reason);
  }

  /// 用户主动登出后调用。
  void markSignedOut() {
    _transitionTo(AuthStatus.unauthenticated, reason: 'sign_out');
  }

  /// 记录登录后需要回跳的位置。
  void rememberPendingLocation(String location) {
    if (location.isEmpty) {
      return;
    }
    _pendingLocation = location;
  }

  /// 取走并清空待回跳位置，保证只消费一次。
  String? consumePendingLocation() {
    final String? location = _pendingLocation;
    _pendingLocation = null;
    return location;
  }

  void _transitionTo(AuthStatus next, {required String reason}) {
    final bool statusChanged = _status != next;
    _status = next;
    _lastReason = reason;
    if (next == AuthStatus.unauthenticated) {
      // 会话已结束，不再回跳旧页面。
      _pendingLocation = null;
    }
    if (!statusChanged) {
      return;
    }
    AppLogger.info(
      'Session status changed',
      loggerName: 'SessionController',
      context: <String, Object?>{'status': next.name, 'reason': reason},
    );
    notifyListeners();
  }
}
