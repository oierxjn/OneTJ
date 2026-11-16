import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/login/application/login_data_service.dart';
import 'package:onetj/features/settings/application/logout_service.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/models/logout_result.dart';
import 'package:onetj/app/presentation/base_view_model.dart';

class LoginViewModel extends BaseViewModel<UiEvent> {
  LoginViewModel({
    required LoginDataService dataService,
    required SessionController sessionController,
    required LogoutService logoutService,
  })  : _dataService = dataService,
        _sessionController = sessionController,
        _logoutService = logoutService;

  final LoginDataService _dataService;
  final SessionController _sessionController;
  final LogoutService _logoutService;

  /// 「以游客身份继续」是否正在处理（清理 + 状态翻转）。
  bool _continuingAsGuest = false;
  bool get continuingAsGuest => _continuingAsGuest;

  Uri get authUri => _dataService.authUri;

  /// 以游客身份继续：清空本机登录态数据后进入游客态。
  ///
  /// 幂等：已是游客直接返回 true。全有或全无：缓存或令牌清理失败时
  /// emit SnackBar 并停留原态、返回 false（不允许带着残留个人数据进入
  /// 游客态）；仅 Cookie 残留失败时仍进入游客态并发降级警告。
  Future<bool> continueAsGuest() async {
    if (_sessionController.status == AuthStatus.guest) {
      return true;
    }
    if (_continuingAsGuest) {
      return false;
    }
    _continuingAsGuest = true;
    notifyListeners();
    try {
      final LogoutResult result = await _logoutService.clearLocalSessionData();
      _sessionController.continueAsGuest();
      if (!result.isFullyClean) {
        // 与设置页登出一致的降级警告：已进入游客态，仅 Cookie 残留失败。
        emit(LogoutCompletedWithWarningEvent(
          failedSteps: result.residualFailures.keys.toList(growable: false),
        ));
      }
      return true;
    } catch (error) {
      emit(ShowSnackBarEvent(
        message: 'Failed to continue as guest: $error',
        code: error is LogoutCleanupException
            ? LogoutCleanupException.errorCode
            : null,
      ));
      return false;
    } finally {
      _continuingAsGuest = false;
      notifyListeners();
    }
  }

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
        // 只更新会话状态：跳转由路由守卫依据新状态完成（回首页）。
        AppLogger.logNavigation(
          from: RoutePaths.login,
          to: RoutePaths.home,
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
