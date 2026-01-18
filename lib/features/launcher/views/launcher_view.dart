import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LauncherView extends StatefulWidget {
  const LauncherView({super.key});

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Hive.initFlutter();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appTitle),
      ),
      body: Center(
        child: Image.asset('assets/icon/logo.jpg'),
      ),
    );
  }
}
