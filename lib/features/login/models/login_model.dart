import 'package:uuid/uuid.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';

/// 登录用的 OAuth 授权参数与回调解析。
///
/// 只负责纯逻辑：拼装授权 URI、校验并解析回调 URI，不做任何 I/O。
/// 授权码到令牌的交换由 `LoginDataService` 编排。
class LoginModel {
  LoginModel({String? state}) : _state = state ?? const Uuid().v4();

  final String _state;
  final String _baseUrl = tongjiApiBaseUrl;
  final String _path = loginEndpointPath;

  final String _responseType = 'code';
  final String _scope = oauthScope.join(' ');
  final String _kcIdpHint = 'tjiam';
  final String _clientId = tongjiClientID;

  final String _redirectUri = oneTJredirectUri;

  Uri buildAuthUri() {
    return Uri.https(
      _baseUrl,
      _path,
      {
        'response_type': _responseType,
        'client_id': _clientId,
        'redirect_uri': _redirectUri,
        'scope': _scope,
        'state': _state,
        'kc_idp_hint': _kcIdpHint,
      },
    );
  }

  /// 校验并解析回调 URI，返回授权码。
  ///
  /// 如果 URI 不是重定向 URI，返回 null。
  /// 如果重定向携带 `error`（如 `invalid_scope`）或缺少 `code`，
  /// 抛出 [AuthRedirectException]，不会拿空 code 去请求 token 接口。
  /// 如果 state 不匹配，抛出 [AuthStateMismatchException]。
  String? parseAuthorizationCode(WebUri uri) {
    if (!uri.toString().startsWith(_redirectUri)) {
      return null;
    }
    final String? error = uri.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      throw AuthRedirectException(
        error: error,
        errorDescription: uri.queryParameters['error_description'],
      );
    }
    final String code = uri.queryParameters['code'] ?? '';
    if (code.isEmpty) {
      throw AuthRedirectException(error: 'missing_code');
    }
    final String state = uri.queryParameters['state'] ?? '';
    if (state != _state) {
      throw AuthStateMismatchException();
    }
    return code;
  }
}
