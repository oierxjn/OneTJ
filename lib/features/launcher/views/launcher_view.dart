import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/launcher/view_models/launcher_view_model.dart';
import 'package:onetj/models/event_model.dart';

class LauncherView extends StatefulWidget {
  const LauncherView({super.key});

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  static Future<void>? _initFuture;
  late final LauncherViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = LauncherViewModel();
    _eventSub = _viewModel.events.listen((event) {
      if (event is NavigateEvent) {
        if (!mounted) return;
        context.go(event.route);
      }
    });
    _initFuture ??= _viewModel.initialize();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _viewModel.dispose();
    super.dispose();
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
