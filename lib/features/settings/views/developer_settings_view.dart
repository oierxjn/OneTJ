import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/view_models/developer_settings_view_model.dart';
import 'package:onetj/models/event_model.dart';

class DeveloperSettingsView extends StatefulWidget {
  const DeveloperSettingsView({super.key});

  @override
  State<DeveloperSettingsView> createState() => _DeveloperSettingsViewState();
}

class _DeveloperSettingsViewState extends State<DeveloperSettingsView> {
  late final DeveloperSettingsViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = DeveloperSettingsViewModel();
    _eventSub = _viewModel.events.listen((UiEvent event) {
      if (!mounted) {
        return;
      }
      final AppLocalizations l10n = AppLocalizations.of(context);
      if (event is DeveloperDebugUploadSuccessEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsDebugUploadSuccess)),
        );
        return;
      }
      if (event is DeveloperDebugUploadFailedEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.settingsDebugUploadFailed(event.message ?? ''),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _sendDebugCollection() async {
    await _viewModel.sendDebugCollection();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsDeveloperPageTitle),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(l10n.settingsLogsTitle),
                subtitle: Text(l10n.settingsLogsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(RoutePaths.homeSettingsDeveloperLogs),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.send_to_mobile_outlined),
                title: Text(l10n.settingsDebugUploadTitle),
                subtitle: Text(l10n.settingsDebugUploadSubtitle),
                trailing: _viewModel.sendingDebug
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _viewModel.sendingDebug ? null : _sendDebugCollection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
