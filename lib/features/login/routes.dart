import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/login/views/login_view.dart';
import 'package:onetj/services/webview_environment_service.dart';

final List<GoRoute> loginRoutes = [
  GoRoute(
    path: RoutePaths.login,
    name: 'login',
    builder: (context, state) => LoginView(
      webViewEnvironment: WebViewEnvironmentService.instance.environment,
    ),
  ),
];
