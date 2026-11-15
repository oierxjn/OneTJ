import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/session/session_controller.dart';

/// 启动页是「状态未知」期间的占位页：引导完成后必须离开，因此它只在
/// [AuthStatus.unknown] 下被放行。登录页承载 OAuth 流程，任何状态下都可访问。
bool _isBootPlaceholder(String location) => location == RoutePaths.launcher;

/// 需要从学校平台拉取个人数据的页面（含其二级详情页）。
///
/// 游客态（[AuthStatus.guest]）下这些路径会被拦到登录页；其余路径
/// （仪表盘、工具/物理实验、设置及其子页）对游客开放。
/// 失效态（[AuthStatus.expired]）不拦截任何页面：本机缓存仍可读，
/// 是否重新登录由用户决定。
bool requiresAuthentication(String location) {
  return location == RoutePaths.homeTimetable ||
      location == RoutePaths.homeGrades ||
      location == RoutePaths.homeCetScore ||
      location == RoutePaths.homeStudentExams;
}

/// 会话状态与目标路径共同决定的一次跳转决策。
///
/// 把「跳到哪里」与两项待施加的副作用都表达为纯数据，使全部状态转移都能
/// 脱离 widget 树单测；真正的副作用由路由层施加。
class AuthRedirectDecision {
  const AuthRedirectDecision({
    this.redirectTo,
    this.rememberLocation = false,
    this.consumePendingLocation = false,
  });

  /// 需要重定向到的路径；为 null 表示放行当前导航。
  final String? redirectTo;

  /// 是否应记住当前位置，供登录成功后回跳。
  final bool rememberLocation;

  /// 本次决策是否使用了待回跳位置。
  ///
  /// 为 true 时路由层应在跳转后清除它，以保持「只消费一次」语义：否则登录
  /// 成功后该值会残留到下一次登出/失效，之后任何以已登录身份进入登录页的
  /// 场景都会跳到这个过期目标，而非首页。
  final bool consumePendingLocation;

  @override
  String toString() =>
      'AuthRedirectDecision(redirectTo: $redirectTo, '
      'rememberLocation: $rememberLocation, '
      'consumePendingLocation: $consumePendingLocation)';
}

/// 根据会话状态与目标路径计算跳转决策。
///
/// 纯函数：不读环境、不写状态、不做网络请求。因此可以穷举测试全部状态
/// 组合，包括最容易出错的「重定向到自身」循环。
///
/// * [AuthStatus.unknown]：引导未结束，一律放行，停留在启动页。
/// * 已登录且停在启动页/登录页：跳向待回跳位置或首页，并消费待回跳位置。
/// * 失效态：不强制跳转，所有页面（含登录页）放行——缓存仍可读，重新登录
///   入口必须可达；仅启动页跳向首页。
/// * 游客态：登录页与公开页放行，数据页（见 [requiresAuthentication]）跳到
///   登录页并记下待回跳位置；启动页跳向首页而非登录页，登录与否由用户决定。
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
        final bool hasPending =
            pendingLocation != null && pendingLocation.isNotEmpty;
        return AuthRedirectDecision(
          redirectTo: hasPending ? pendingLocation : RoutePaths.home,
          consumePendingLocation: hasPending,
        );
      }
      return const AuthRedirectDecision();

    case AuthStatus.expired:
      // 失效态不强制跳转：缓存仍可读，用户停在哪一层都不被打断。
      if (_isBootPlaceholder(location)) {
        return const AuthRedirectDecision(redirectTo: RoutePaths.home);
      }
      // 登录页放行——「重新登录」入口必须可达；登录成功后由
      // authenticated 分支按待回跳位置离开。
      return const AuthRedirectDecision();

    case AuthStatus.guest:
      if (location == RoutePaths.login) {
        // 放行登录页本身，避免「游客 → 跳登录 → 仍是游客」的死循环。
        return const AuthRedirectDecision();
      }
      if (_isBootPlaceholder(location)) {
        // 启动引导结束后不再强制登录：落到首页，由用户决定是否登录。
        // 启动页不记入回跳目标，否则登录成功后会被送回启动页形成循环。
        return const AuthRedirectDecision(redirectTo: RoutePaths.home);
      }
      if (requiresAuthentication(location)) {
        return AuthRedirectDecision(
          redirectTo: RoutePaths.login,
          rememberLocation: true,
        );
      }
      return const AuthRedirectDecision();
  }
}