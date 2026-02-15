import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/view_models/settings_view_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/time_slot.dart';
import 'package:onetj/repo/settings_repository.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;
  late final TextEditingController _maxWeekController;
  List<int> _draftTimeSlotStartMinutes =
      List<int>.from(TimeSlot.defaultStartMinutes);

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
        _applySettingsToControllers(event.settings);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsSaved)),
        );
        return;
      }
      if (event is SettingsResetEvent) {
        _applySettingsToControllers(event.settings);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsResetDone)),
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
    _applySettingsToControllers(
      SettingsData(
        maxWeek: _viewModel.maxWeek,
        timeSlotStartMinutes: _viewModel.timeSlotStartMinutes,
      ),
    );
  }

  void _submitMaxWeek() {
    final int? value = int.tryParse(_maxWeekController.text);
    if (value == null || value <= 0) {
      // TODO: 提示用户输入合法的最大周数
      return;
    }
    _submitSettings();
  }

  void _applySettingsToControllers(SettingsData settings) {
    _maxWeekController.text = settings.maxWeek.toString();
    _draftTimeSlotStartMinutes = List<int>.from(settings.timeSlotStartMinutes);
  }

  Future<void> _submitSettings() async {
    try {
      final int maxWeek = int.parse(_maxWeekController.text);
      await _viewModel.saveSettings(
        maxWeek: maxWeek,
        timeSlotStartMinutes: _draftTimeSlotStartMinutes,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
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

  Future<void> _confirmResetSettings(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).settingsResetConfirmTitle),
        content: Text(AppLocalizations.of(context).settingsResetConfirmLabel),
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
    await _viewModel.resetSettings();
  }

  Future<void> _openTimeSlotEditor() async {
    final List<int>? next = await context.push<List<int>>(
      RoutePaths.homeSettingsTimeSlots,
      extra: List<int>.from(_draftTimeSlotStartMinutes),
    );
    if (next == null || !mounted) {
      return;
    }
    setState(() {
      _draftTimeSlotStartMinutes = List<int>.from(next);
    });
  }

  String _timeSlotSummary(AppLocalizations l10n) {
    if (_draftTimeSlotStartMinutes.isEmpty) {
      return l10n.settingsTimeSlotsEmpty;
    }
    final String first =
        TimeSlot.formatMinutes(_draftTimeSlotStartMinutes.first);
    final String last = TimeSlot.formatMinutes(_draftTimeSlotStartMinutes.last);
    return l10n.settingsTimeSlotsSummary(
      _draftTimeSlotStartMinutes.length,
      first,
      last,
    );
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
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title:
                    Text(AppLocalizations.of(context).settingsTimeSlotsTitle),
                subtitle: Text(_timeSlotSummary(AppLocalizations.of(context))),
                trailing: const Icon(Icons.chevron_right),
                onTap: _viewModel.settingsLoading || _viewModel.settingsSaving
                    ? null
                    : _openTimeSlotEditor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).settingsAdvancedSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.restore),
                title: Text(AppLocalizations.of(context).settingsResetTitle),
                subtitle:
                    Text(AppLocalizations.of(context).settingsResetSubtitle),
                onTap: _viewModel.settingsLoading || _viewModel.settingsSaving
                    ? null
                    : () => _confirmResetSettings(context),
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
