import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';

class LauncherView extends StatefulWidget {
  const LauncherView({super.key});

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  static Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture ??= _initializeApp();
  }

  Future<void> _initializeApp() async {
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // Basic log sink for logging package.
      // ignore: avoid_print
      print('${record.time} [${record.level.name}] ${record.loggerName}: ${record.message}');
    });
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
