import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';


import 'package:onetj/models/event_model.dart';
import 'package:onetj/app/exception/app_exception.dart';

import '../view_models/login_view_model.dart';

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
        return;
      }
      if (event is NavigateEvent) {
        if (!mounted) return;
        context.go(event.route);
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
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(viewModel.authUri.toString()),
        ),
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          print('shouldOverrideUrlLoading: ${navigationAction.request.url}');
          if (navigationAction.request.url == null) {
            return NavigationActionPolicy.ALLOW;
          }
          return await viewModel.handleRedirectUri(controller, navigationAction.request.url!);
        },
      ),
    );
  }
}
