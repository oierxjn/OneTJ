import 'package:flutter/material.dart';

import 'package:onetj/app/theme/theme_change_notifier.dart';

/// 为主页 Shell 及其子路由提供可监听的主页布局状态。
///
/// 子页面通过 [of] 建立依赖后，即使页面被
/// [StatefulShellRoute.indexedStack] 缓存，也会在布局切换时重新构建。
class HomeShellLayoutScope extends InheritedNotifier<ThemeChangeNotifier> {
  const HomeShellLayoutScope({
    required ThemeChangeNotifier notifier,
    required super.child,
    super.key,
  }) : super(notifier: notifier);

  /// 返回主页 Shell 内的主题通知器。
  ///
  /// [buildHomeShellBackButton] 仅用于主页 Shell 的功能子页面，因此在
  /// 作用域缺失时抛出明确错误，而不是回退到全局服务定位器。
  static ThemeChangeNotifier of(BuildContext context) {
    final ThemeChangeNotifier? notifier = context
        .dependOnInheritedWidgetOfExactType<HomeShellLayoutScope>()
        ?.notifier;

    if (notifier == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('当前 BuildContext 中未找到 HomeShellLayoutScope。'),
        ErrorDescription(
          'buildHomeShellBackButton 仅能用于主页 Shell 内的功能页面。',
        ),
        ErrorHint(
          '请确认该页面由 HomeView / StatefulShellRoute 的子路由构建。',
        ),
      ]);
    }

    return notifier;
  }
}
