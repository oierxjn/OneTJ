import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/login/application/login_data_service.dart';
import 'package:onetj/features/login/view_models/login_view_model.dart';
import 'package:onetj/features/login/views/login_view.dart';
import 'package:onetj/services/webview_environment_service.dart';

final List<GoRoute> loginRoutes = [
  GoRoute(
    path: RoutePaths.login,
    name: 'login',
    builder: (context, state) {
      final SessionController session = appLocator<SessionController>();
      return LoginView(
        viewModel: LoginViewModel(
          dataService: appLocator<LoginDataService>(),
          sessionController: session,
        ),
        sessionStatus: session.status,
        sessionLastReason: session.lastReason,
        webViewEnvironment:
            appLocator<WebViewEnvironmentService>().environment,
      );
    },
  ),
];
