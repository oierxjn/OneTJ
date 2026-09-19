import 'package:flutter/material.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/home/views/widgets/home_shell_layout_scope.dart';
import 'package:onetj/models/theme_preferences.dart';

/// 返回功能网格首页的按钮。
///
/// 只有用户启用功能网格主页时才返回按钮，默认底部导航布局返回 null；
/// 由一级页面顶部的纤细导航行（HomeSlimHeader）承载。
Widget? buildHomeShellBackButton(BuildContext context) {
  final themeChangeNotifier = HomeShellLayoutScope.of(context);
  if (themeChangeNotifier.preferences.homeLayout != HomeLayout.functionGrid) {
    return null;
  }

  return TextButton.icon(
    onPressed: () => context.go(RoutePaths.homeDashboard),
    icon: const Icon(Icons.arrow_back, size: 20),
    label: Text(AppLocalizations.of(context).gridHomeBackToHome),
  );
}
