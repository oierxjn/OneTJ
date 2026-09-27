import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/session/session_controller.dart';

/// 启动页是「状态未知」期间的占位页：引导完成后必须离开，因此它只在
/// [AuthStatus.unknown] 下被放行。登录页承载 OAuth 流程，任何状态下都可访问。
bool _isBootPlaceholder(String location) => location == RoutePaths.launcher;

/// 会话状态与目标路径共同决定的一次跳转决策。
///
/// 把「跳到哪里」与「是否记下当前位置以便登录后回跳」都表达为纯数据，
/// 使全部状态转移都能脱离 widget 树单测；真正的副作用由路由层施加。
class AuthRedirectDecision {
  const AuthRedirectDecision({this.redirectTo, this.rememberLocation = false});

  /// 需要重定向到的路径；为 null 表示放行当前导航。
  final String? redirectTo;

  /// 是否应记住当前位置，供登录成功后回跳。
  final bool rememberLocation;

  @override
  String toString() =>
      'AuthRedirectDecision(redirectTo: $redirectTo, '
      'rememberLocation: $rememberLocation)';
}

/// 根据会话状态与目标路径计算跳转决策。
///
/// 纯函数：不读环境、不写状态、不做网络请求。因此可以穷举测试全部状态
/// 组合，包括最容易出错的「重定向到自身」循环。
///
/// * [AuthStatus.unknown]：引导未结束，一律放行，停留在启动页。
/// * 已登录且停在启动页/登录页：跳向待回跳位置或首页。
/// * 未登录：登录页放行，其余（含启动页）跳到登录页，并记下待回跳位置。
AuthRedirectDecision resolveAuthDecision({
  required AuthStatus status,
  required String location,
  String? pendingLocation,
}) {
  switch (status) {
    case AuthStatus.unknown:
      return const AuthRedirectDecision();

    case AuthStatus.authenticated:
      if (_isBootPlaceholder(location) || location == RoutePaths.login) {
        final String target =
            (pendingLocation != null && pendingLocation.isNotEmpty)
                ? pendingLocation
                : RoutePaths.home;
        return AuthRedirectDecision(redirectTo: target);
      }
      return const AuthRedirectDecision();

    case AuthStatus.unauthenticated:
      if (location == RoutePaths.login) {
        // 放行登录页本身，避免「未登录 → 跳登录 → 仍是未登录」的死循环。
        return const AuthRedirectDecision();
      }
      return AuthRedirectDecision(
        redirectTo: RoutePaths.login,
        // 启动页不记入回跳目标，否则登录成功后会被送回启动页形成循环。
        rememberLocation: !_isBootPlaceholder(location),
      );
  }
}
