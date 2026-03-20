import 'package:flutter/material.dart';

import 'package:onetj/services/app_update_service.dart';

class AppLifecycleHost extends StatefulWidget {
  const AppLifecycleHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppLifecycleHost> createState() => _AppLifecycleHostState();
}

class _AppLifecycleHostState extends State<AppLifecycleHost>
    with WidgetsBindingObserver {
  final AppUpdateService _appUpdateService = AppUpdateService.getInstance();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumePendingInstall();
    }
  }

  void _resumePendingInstall() {
    _appUpdateService.resumePendingInstallIfPossible().catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _appUpdateService.logUpdateFailure(error, stackTrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
