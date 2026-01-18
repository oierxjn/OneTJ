import '../models/login_model.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../models/base_model.dart';

class LoginViewModel extends BaseModel {
  LoginViewModel({
    LoginModel? model,
  }) : _model = model ?? LoginModel();

  final LoginModel _model;

  Uri get authUri => _model.buildAuthUri();

  Future<void> handleRedirectUri(InAppWebViewController controller, WebUri uri) async {
    await _model.handleRedirectUri(controller, uri);
  }
}
