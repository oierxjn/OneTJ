import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/features/login/models/login_model.dart';
import 'package:onetj/services/auth_token_provider.dart';

/// 登录流程编排：构造授权地址、处理回调并交换令牌。
///
/// 授权参数的拼装与回调校验属于纯逻辑，放在 [LoginModel]；
/// 本服务只负责把「解析出的授权码」交给 [AuthTokenProvider] 交换令牌。
class LoginDataService {
  LoginDataService({
    required LoginModel model,
    required AuthTokenProvider authTokenProvider,
  })  : _model = model,
        _authTokenProvider = authTokenProvider;

  final LoginModel _model;
  final AuthTokenProvider _authTokenProvider;

  /// 待加载的 OAuth 授权地址。
  Uri get authUri => _model.buildAuthUri();

  /// 处理重定向 URI，必要时交换令牌。
  ///
  /// 返回 true 表示该 URI 是本次登录回调且令牌交换成功，调用方应继续导航；
  /// 返回 false 表示不是回调 URI。
  /// 校验失败时抛出 [AuthRedirectException] / [AuthStateMismatchException]。
  Future<bool> exchangeCodeIfRedirect(WebUri uri) async {
    final String? code = _model.parseAuthorizationCode(uri);
    if (code == null) {
      return false;
    }
    await _authTokenProvider.exchangeCode(code);
    return true;
  }
}
