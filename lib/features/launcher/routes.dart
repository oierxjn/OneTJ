import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/launcher/application/launcher_boot_service.dart';
import 'package:onetj/features/launcher/view_models/launcher_view_model.dart';
import 'package:onetj/features/launcher/views/launcher_view.dart';

final List<GoRoute> launcherRoutes = [
  GoRoute(
    path: RoutePaths.launcher,
    name: 'launcher',
    builder: (context, state) => LauncherView(
      viewModel: LauncherViewModel(
        bootService: appLocator<LauncherBootService>(),
        sessionController: appLocator<SessionController>(),
      ),
    ),
  ),
];
