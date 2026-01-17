import 'package:uuid/uuid.dart';
import 'package:onetj/app/constant/site_constant.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:onetj/app/exception/app_exception.dart';

class LoginModel {
  final String _baseUrl = 'api.tongji.edu.cn';
  final String _path = '/keycloak/realms/OpenPlatform/protocol/openid-connect/auth';

  final String _responseType = 'code';
  final String _scope = oauthScope.join(' ');
  final String _kcIdpHint = 'tjiam';
  final String _clientId = 'authorization-xxb-onedottongji-yuchen';

  final String _redirectUri = 'onetj://fakeredir.jkljkluiouio.top';

  final String _state = Uuid().v4();

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

  void handleRedirectUri(InAppWebViewController controller, WebUri uri) {
    if (uri.toString().startsWith(_redirectUri)) {
      final code = uri.queryParameters['code'] ?? '';
      final state = uri.queryParameters['state'] ?? '';
      if (state != _state) {
        throw AuthStateMismatchException();
      }
      // TODO: 处理 code，例如发送到服务器进行交换 token
    }
  }

}
