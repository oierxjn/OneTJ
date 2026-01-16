import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一统同济'),
      ),
      body: Center(
        child: Image.asset('assets/pictures/1.jpg'),
      ),
    );
  }
}