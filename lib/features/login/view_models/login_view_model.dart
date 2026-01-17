import '../models/login_model.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoginViewModel {
  LoginViewModel({
    LoginModel? model,
  }) : _model = model ?? LoginModel();

  final LoginModel _model;

  Uri get authUri => _model.buildAuthUri();

  void handleRedirectUri(InAppWebViewController controller, WebUri uri) {
    _model.handleRedirectUri(controller, uri);
  }
}
