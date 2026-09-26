import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/features/login/models/login_model.dart';
import 'package:onetj/features/login/view_models/login_view_model.dart';
import 'package:onetj/features/login/views/login_view.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/webview_environment_service.dart';

final List<GoRoute> loginRoutes = [
  GoRoute(
    path: RoutePaths.login,
    name: 'login',
    builder: (context, state) => LoginView(
      viewModel: LoginViewModel(
        model: LoginModel(auth: appLocator<AuthTokenProvider>()),
      ),
      webViewEnvironment: WebViewEnvironmentService.instance.environment,
    ),
  ),
];
