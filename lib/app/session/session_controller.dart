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
/// 监听的状态：状态变化会触发守卫重新求值（启动页/登录页出口）。
///
/// 本类只负责保存状态，不含路由知识。登录是可选的：守卫不再拦截数据页，
/// 需登录的页面由各视图按 [status] 自行展示登录引导。
class SessionController extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _lastReason;

  AuthStatus get status => _status;

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

  /// 用户主动选择「以游客身份继续」时调用（如登录页的游客按钮）。
  ///
  /// 幂等：已处于 [AuthStatus.guest] 时完全无副作用——不通知、不改原因。
  /// 调用方须先清空本机个人数据（令牌/缓存/Cookie），再调用本方法；
  /// 本方法只负责状态翻转，不做清理。
  void continueAsGuest() {
    if (_status == AuthStatus.guest) {
      return;
    }
    _transitionTo(AuthStatus.guest, reason: 'continue_as_guest');
  }

  void _transitionTo(AuthStatus next, {required String reason}) {
    final bool statusChanged = _status != next;
    _status = next;
    _lastReason = reason;
    if (!statusChanged) {
      // 重复上报（如多个并发请求同时收到 401）：状态未变，不通知。
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
