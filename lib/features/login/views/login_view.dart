import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../view_models/login_view_model.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = LoginViewModel();

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
