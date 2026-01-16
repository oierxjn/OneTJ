import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LancherView extends StatefulWidget {
  const LancherView({super.key});

  @override
  State<LancherView> createState() => _LancherViewState();
}

class _LancherViewState extends State<LancherView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('一统同济'),
      ),
      body: Center(
        child: Image.asset('assets/icon/logo.jpg'),
      ),
    );
  }
}
