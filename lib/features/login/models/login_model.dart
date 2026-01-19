import 'package:uuid/uuid.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/constant/site_constant.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/services/tongji.dart';

class LoginModel {
  final String _baseUrl = tongjiApiBaseUrl;
  final String _path = loginEndpointPath;

  final String _responseType = 'code';
  final String _scope = oauthScope.join(' ');
  final String _kcIdpHint = 'tjiam';
  final String _clientId = tongjiClientID;

  final String _redirectUri = oneTJredirectUri;

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

  Future<NavigationActionPolicy> handleRedirectUri(InAppWebViewController controller, WebUri uri) async {
    if (uri.toString().startsWith(_redirectUri)) {
      final code = uri.queryParameters['code'] ?? '';
      final state = uri.queryParameters['state'] ?? '';
      if (state != _state) {
        throw AuthStateMismatchException();
      }
      final TongjiApi api = TongjiApi();
      await api.code2token(code);
      return NavigationActionPolicy.CANCEL;
    }
    return NavigationActionPolicy.ALLOW;
  }

}
