import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/tools/views/tools_view.dart';

final List<GoRoute> toolsRoutes = [
  GoRoute(
    path: RoutePaths.homeTools,
    name: 'tools',
    builder: (context, state) => const ToolsView(),
  ),
];
