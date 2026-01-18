import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:onetj/models/event_model.dart';

import '../view_models/login_view_model.dart';
import '../../../app/exception/app_exception.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel viewModel;
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    viewModel = LoginViewModel();

    // 订阅Stream事件
    _eventSub = viewModel.events.listen((event) {
      if (event is ShowSnackBarEvent) {
        if(!mounted)return;
        if(event.code == AuthStateMismatchException().code){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).authStateMismatch)),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(viewModel.authUri.toString()),
        ),
        onLoadStart: (controller, url) async {
          if (url == null) {
            return;
          }
          await viewModel.handleRedirectUri(controller, url);
        },
      ),
    );
  }
}
