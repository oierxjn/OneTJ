import 'package:flutter/material.dart';
import 'package:onetj/widgets/adaptive_webview.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final url = Uri.parse('https://www.baidu.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('一统同济'),
      ),
      body: AdaptiveWebView(initialUrl: url),
    );
  }
}