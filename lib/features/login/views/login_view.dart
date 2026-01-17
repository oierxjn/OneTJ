import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../view_models/login_view_model.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = LoginViewModel();

    return Scaffold(
      appBar: AppBar(
        title: const Text('一统同济'),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(viewModel.authUri.toString()),
        ),
        onLoadStart: (controller, url) {
          if (url == null) {
            return;
          }
          viewModel.handleRedirectUri(controller, url);
        },
      ),
    );
  }
}
