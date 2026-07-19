import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/home/views/widgets/home_shell_layout_scope.dart';
import 'package:onetj/models/theme_preferences.dart';

/// 功能网格主页返回按钮在应用栏中占用的宽度。
///
/// 宽度同时容纳中文和英文标签。
const double homeShellBackButtonLeadingWidth = 144;

/// 返回功能网格首页的应用栏入口。
///
/// 只有用户启用功能网格主页时才显示，默认底部导航布局不改变原有应用栏。
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
