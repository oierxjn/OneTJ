import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/tools/views/tools_view.dart';

/// 主页 Shell 中的工具一级页面。
final List<GoRoute> toolsShellRoutes = [
  GoRoute(
    path: RoutePaths.homeTools,
    name: 'tools',
    builder: (context, state) => const ToolsView(),
  ),
];
