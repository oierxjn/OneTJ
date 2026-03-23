import 'package:flutter/material.dart';

import 'package:onetj/services/app_update_service.dart';

class AppLifecycleHost extends StatefulWidget {
  const AppLifecycleHost({
    super.key,
    required this.appUpdateService,
    required this.child,
  });

  final AppUpdateService appUpdateService;
  final Widget child;

  @override
  State<AppLifecycleHost> createState() => _AppLifecycleHostState();
}

class _AppLifecycleHostState extends State<AppLifecycleHost>
    with WidgetsBindingObserver {
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
    widget.appUpdateService.resumePendingInstallIfPossible().catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      widget.appUpdateService.logUpdateFailure(error, stackTrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
