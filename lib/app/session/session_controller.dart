import 'package:flutter/foundation.dart';

import 'package:onetj/app/logging/logger.dart';

/// 会话鉴权状态。
///
/// [unknown] 表示启动引导（Hive / 主题 / 令牌校验）与启动页最短展示时间
/// 尚未结束。守卫在 [unknown] 下不做任何跳转，避免初始位置抖动。
///
/// [expired] 与 [guest] 都表示「当前没有可用令牌」，但数据语义不同：
/// * [expired]：本机仍持有令牌但已失效，个人数据缓存保留，重新登录即可恢复；
/// * [guest]：从未登录或已主动登出，无个人数据缓存，是否登录由用户决定。
enum AuthStatus { unknown, authenticated, expired, guest }

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
  /// 进入 [AuthStatus.expired]：本机缓存保留，用户重新登录即可恢复。
  /// 处于 [AuthStatus.unknown] 时忽略：启动期的校验失败由
  /// [LauncherBootService] 自行决定初始状态，不应在启动页未结束时触发跳转。
  void markUnauthenticated({required String reason}) {
    if (_status == AuthStatus.unknown) {
      return;
    }
    _transitionTo(AuthStatus.expired, reason: reason);
  }

  /// 用户主动登出后调用。
  ///
  /// 进入 [AuthStatus.guest]：登出编排已清空个人数据缓存，此后以游客身份
  /// 浏览公开页面，是否重新登录由用户决定。
  void markSignedOut() {
    _transitionTo(AuthStatus.guest, reason: 'sign_out');
  }

  /// 记录登录后需要回跳的位置。
  void rememberPendingLocation(String location) {
    if (location.isEmpty) {
      return;
    }
    _pendingLocation = location;
  }

  /// 守卫因数据页拦截而跳向登录页时调用，仅更新原因供登录页横幅使用。
  ///
  /// 不触发通知：这不是会话状态变化，不应引起守卫重新求值。
  void markGuardRedirect() {
    _lastReason = 'guard_redirect';
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
    if (!statusChanged) {
      // 重复上报（如多个并发请求同时收到 401）：状态未变，不做任何清理。
      // 特别是不能清空待回跳位置——它可能正是守卫在处理首次失效时刚记录的。
      return;
    }
    if (next == AuthStatus.expired || next == AuthStatus.guest) {
      // 真正进入无可用令牌状态：上一次会话的待回跳位置已失效，清掉。
      // 注意顺序：随后守卫会在 redirect 中记录本次所在页面。
      _pendingLocation = null;
    }
    AppLogger.info(
      'Session status changed',
      loggerName: 'SessionController',
      context: <String, Object?>{'status': next.name, 'reason': reason},
    );
    notifyListeners();
  }
}
