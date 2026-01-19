import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/features/login/models/login_model.dart';
import 'package:onetj/models/base_model.dart';

class LoginViewModel extends BaseModel {
  LoginViewModel({
    LoginModel? model,
  })  : _model = model ?? LoginModel(),
        _eventController = StreamController<UiEvent>.broadcast();

  final LoginModel _model;
  final StreamController<UiEvent> _eventController;

  Stream<UiEvent> get events => _eventController.stream;

  Uri get authUri => _model.buildAuthUri();

  Future<NavigationActionPolicy> handleRedirectUri(InAppWebViewController controller, WebUri uri) async {
    try {
      final bool shouldNavigate = await _model.exchangeCodeIfRedirect(uri);
      if (shouldNavigate) {
        _eventController.add(const NavigateEvent('/home'));
        return NavigationActionPolicy.CANCEL;
      }
      return NavigationActionPolicy.ALLOW;
    } on AppException catch (e) {
      _eventController.add(ShowSnackBarEvent(message: e.message, code: e.code));
      return NavigationActionPolicy.CANCEL;
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
