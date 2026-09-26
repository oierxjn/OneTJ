import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/theme/theme_change_notifier.dart';
import 'package:onetj/features/launcher/view_models/launcher_view_model.dart';
import 'package:onetj/features/launcher/views/launcher_view.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/services/webview_environment_service.dart';

final List<GoRoute> launcherRoutes = [
  GoRoute(
    path: RoutePaths.launcher,
    name: 'launcher',
    builder: (context, state) => LauncherView(
      viewModel: LauncherViewModel(
        themeChangeNotifier: appLocator<ThemeChangeNotifier>(),
        settingsRepository: appLocator<SettingsRepository>(),
        tokenRepository: appLocator<TokenRepository>(),
        authTokenProvider: appLocator<AuthTokenProvider>(),
        webViewEnvironmentService: appLocator<WebViewEnvironmentService>(),
      ),
    ),
  ),
];
