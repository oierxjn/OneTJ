import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/login/application/login_data_service.dart';
import 'package:onetj/app/presentation/base_view_model.dart';

class LoginViewModel extends BaseViewModel<UiEvent> {
  LoginViewModel({
    required LoginDataService dataService,
    required SessionController sessionController,
  })  : _dataService = dataService,
        _sessionController = sessionController;

  final LoginDataService _dataService;
  final SessionController _sessionController;

  Uri get authUri => _dataService.authUri;

  static Map<String, Object?> redirectUriLogContext(WebUri uri) {
    return <String, Object?>{
      'scheme': uri.scheme,
      'host': uri.host,
      'path': uri.path,
      'queryParameterNames': uri.queryParameters.keys.toList(growable: false),
    };
  }

  Future<NavigationActionPolicy> handleRedirectUri(
      InAppWebViewController controller, WebUri uri) async {
    AppLogger.debug(
      'Handle redirect uri',
      loggerName: 'LoginViewModel',
      context: redirectUriLogContext(uri),
    );
    try {
      final bool shouldNavigate = await _dataService.exchangeCodeIfRedirect(uri);
      if (shouldNavigate) {
        // 只更新会话状态：跳转由路由守卫依据新状态完成（含回跳待处理页面）。
        AppLogger.logNavigation(
          from: RoutePaths.login,
          to: _sessionController.pendingLocation ?? RoutePaths.home,
          context: const <String, Object?>{'source': 'login_success'},
        );
        _sessionController.markAuthenticated();
        return NavigationActionPolicy.CANCEL;
      }
      return NavigationActionPolicy.ALLOW;
    } on AppException catch (e) {
      AppLogger.warning(
        'Login redirect handling failed',
        loggerName: 'LoginViewModel',
        code: e.code,
        error: e,
      );
      emit(ShowSnackBarEvent(message: e.message, code: e.code));
      return NavigationActionPolicy.CANCEL;
    }
  }
}
