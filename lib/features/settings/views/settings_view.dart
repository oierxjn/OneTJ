import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/view_models/settings_view_model.dart';
import 'package:onetj/models/event_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;
  late final TextEditingController _maxWeekController;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    _maxWeekController = TextEditingController();
    _eventSub = _viewModel.events.listen((event) {
      if (!mounted) {
        return;
      }
      if (event is ShowSnackBarEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
        return;
      }
      if (event is NavigateEvent) {
        context.go(event.route);
        return;
      }
      if (event is SettingsSavedEvent) {
        final String maxWeekText = event.maxWeek.toString();
        if (_maxWeekController.text != maxWeekText) {
          _maxWeekController.text = maxWeekText;
        }
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsSaved)),
        );
      }
    });
    _initSettings();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _maxWeekController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _initSettings() async {
    await _viewModel.loadSettings();
    if (!mounted) {
      return;
    }
    _maxWeekController.text = _viewModel.maxWeek.toString();
  }

  void _submitMaxWeek() {
    final int? value = int.tryParse(_maxWeekController.text);
    if (value == null || value <= 0) {
      return;
    }
    _viewModel.saveSettings(value);
  }

  Future<void> _logout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).logOut),
        content: Text(AppLocalizations.of(context).logOutConfirmLabel),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _viewModel.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tabSettings),
        actions: [
          AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) => IconButton(
              tooltip: AppLocalizations.of(context).saveLabel,
              icon: const Icon(Icons.save),
              onPressed: _viewModel.settingsLoading || _viewModel.settingsSaving
                  ? null
                  : _submitMaxWeek,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(AppLocalizations.of(context).settingsMaxWeekTitle),
                subtitle:
                    Text(AppLocalizations.of(context).settingsMaxWeekSubtitle),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _maxWeekController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    enabled: !_viewModel.settingsLoading &&
                        !_viewModel.settingsSaving,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submitMaxWeek(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton(
                onPressed: _viewModel.loading ? null : () => _logout(context),
                child: Text(AppLocalizations.of(context).logOut),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
