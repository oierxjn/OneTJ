import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/features/login/models/login_model.dart';
import 'package:onetj/models/base_model.dart';

class LoginViewModel extends BaseViewModel<UiEvent> {
  LoginViewModel({
    LoginModel? model,
  }) : _model = model ?? LoginModel();

  final LoginModel _model;

  Uri get authUri => _model.buildAuthUri();

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
      final bool shouldNavigate = await _model.exchangeCodeIfRedirect(uri);
      if (shouldNavigate) {
        AppLogger.logNavigation(
          from: RoutePaths.login,
          to: RoutePaths.home,
          context: const <String, Object?>{'source': 'handleRedirectUri'},
        );
        emit(const NavigateEvent(RoutePaths.home));
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
