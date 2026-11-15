import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/session/session_controller.dart';

/// 启动页是「状态未知」期间的占位页：引导完成后必须离开。
bool _isBootPlaceholder(String location) => location == RoutePaths.launcher;

/// 会话状态与目标路径共同决定的一次跳转决策。
///
/// 纯数据：把「跳到哪里」表达为可单测的结果，真正的导航由路由层施加。
class AuthRedirectDecision {
  const AuthRedirectDecision({this.redirectTo});

  /// 需要重定向到的路径；为 null 表示放行当前导航。
  final String? redirectTo;

  @override
  String toString() => 'AuthRedirectDecision(redirectTo: $redirectTo)';
}

/// 根据会话状态与目标路径计算跳转决策。
///
/// 纯函数：不读环境、不写状态、不做网络请求，可穷举测试全部状态组合。
///
/// 登录是可选的：守卫只负责启动页出口与登录成功出口，**不再拦截数据页**。
/// 需登录的数据页（课表/成绩/四六级/考试）由页面自身按会话状态展示登录引导。
///
/// * [AuthStatus.unknown]：引导未结束，一律放行，停留在启动页。
/// * 已登录：停在启动页/登录页时回首页（登录成功出口）；其余放行。
/// * 失效态/游客态：仅启动页跳向首页，其余（含登录页与数据页）一律放行。
AuthRedirectDecision resolveAuthDecision({
  required AuthStatus status,
  required String location,
}) {
  switch (status) {
    case AuthStatus.unknown:
      return const AuthRedirectDecision();

    case AuthStatus.authenticated:
      if (_isBootPlaceholder(location) || location == RoutePaths.login) {
        return const AuthRedirectDecision(redirectTo: RoutePaths.home);
      }
      return const AuthRedirectDecision();

    case AuthStatus.expired:
    case AuthStatus.guest:
      if (_isBootPlaceholder(location)) {
        return const AuthRedirectDecision(redirectTo: RoutePaths.home);
      }
      return const AuthRedirectDecision();
  }
}