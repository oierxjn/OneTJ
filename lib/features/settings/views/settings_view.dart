import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/view_models/settings_view_model.dart';
import 'package:onetj/features/settings/views/widgets/upcoming_courses_card.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/time_period_range.dart';
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
  late final TextEditingController _dashboardCountController;
  List<TimePeriodRangeData> _draftTimeSlotRanges = <TimePeriodRangeData>[];
  DashboardUpcomingMode _draftUpcomingMode = kDefaultDashboardUpcomingMode;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    _maxWeekController = TextEditingController();
    _dashboardCountController = TextEditingController();
    _eventSub = _viewModel.events.listen((event) {
      if (!mounted) {
        return;
      }
      if (event is ShowSnackBarEvent) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_resolveSettingsErrorMessage(l10n, event))),
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
    _dashboardCountController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  String _resolveSettingsErrorMessage(
    AppLocalizations l10n,
    ShowSnackBarEvent event,
  ) {
    switch (event.code) {
      case SettingsValidationException.maxWeekInvalidFormat:
        return l10n.settingsMaxWeekInvalidFormat;
      case SettingsValidationException.maxWeekOutOfRange:
        return l10n.settingsMaxWeekInvalidRange;
      case SettingsValidationException.timeSlotEmpty:
        return l10n.settingsTimeSlotsInvalidEmpty;
      case SettingsValidationException.timeSlotStartOutOfRange:
      case SettingsValidationException.timeSlotEndOutOfRange:
      case SettingsValidationException.timeSlotRangeInvalid:
      case SettingsValidationException.timeSlotStartMinutesItemOutOfRange:
        return l10n.settingsTimeSlotsInvalidRange;
      case SettingsValidationException.timeSlotOrderInvalid:
      case SettingsValidationException.timeSlotStartMinutesNotIncreasing:
        return l10n.settingsTimeSlotsInvalidOrder;
      case SettingsValidationException.timeSlotOverlap:
        return l10n.settingsTimeSlotsInvalidOverlap;
      case SettingsValidationException.dashboardUpcomingCountInvalidFormat:
        return l10n.settingsDashboardUpcomingCountInvalidFormat;
      case SettingsValidationException.dashboardUpcomingCountOutOfRange:
        return l10n.settingsDashboardUpcomingCountInvalidRange;
      default:
        return event.message ?? '';
    }
  }

  Future<void> _initSettings() async {
    await _viewModel.loadSettings();
    if (!mounted) {
      return;
    }
    _applySettingsToControllers(_viewModel.settingsData);
  }

  void _applySettingsToControllers(SettingsData settings) {
    _maxWeekController.text = settings.maxWeek.toString();
    _dashboardCountController.text = settings.dashboardUpcomingCount.toString();
    final List<TimePeriodRangeData> nextRanges = settings.timeSlotRanges
        .map(
          (item) => TimePeriodRangeData(
            startMinutes: item.startMinutes,
            endMinutes: item.endMinutes,
          ),
        )
        .toList(growable: false);
    if (mounted) {
      setState(() {
        _draftTimeSlotRanges = nextRanges;
        _draftUpcomingMode = settings.dashboardUpcomingMode;
      });
      return;
    }
    _draftTimeSlotRanges = nextRanges;
    _draftUpcomingMode = settings.dashboardUpcomingMode;
  }

  Future<void> _submitSettings() async {
    await _viewModel.saveSettings(
      maxWeekText: _maxWeekController.text,
      editedTimeSlotRanges: _draftTimeSlotRanges,
      dashboardUpcomingMode: _draftUpcomingMode,
      dashboardUpcomingCountText: _dashboardCountController.text,
    );
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
    final List<TimePeriodRangeData>? next =
        await context.push<List<TimePeriodRangeData>>(
      RoutePaths.homeSettingsTimeSlots,
      extra: _draftTimeSlotRanges
          .map(
            (item) => TimePeriodRangeData(
              startMinutes: item.startMinutes,
              endMinutes: item.endMinutes,
            ),
          )
          .toList(growable: false),
    );
    if (next == null || !mounted) {
      return;
    }
    setState(() {
      _draftTimeSlotRanges = next;
    });
  }

  String _timeSlotSummary(AppLocalizations l10n) {
    if (_draftTimeSlotRanges.isEmpty) {
      return l10n.settingsTimeSlotsEmpty;
    }
    final String first = TimeSlot.formatMinutes(
      _draftTimeSlotRanges.first.startMinutes,
    );
    final String last = TimeSlot.formatMinutes(
      _draftTimeSlotRanges.last.endMinutes,
    );
    return l10n.settingsTimeSlotsSummary(
      _draftTimeSlotRanges.length,
      first,
      last,
    );
  }

  String _dashboardUpcomingSummary(AppLocalizations l10n) {
    switch (_draftUpcomingMode) {
      case DashboardUpcomingMode.thisWeek:
        return l10n.settingsDashboardUpcomingModeThisWeek;
      case DashboardUpcomingMode.today:
        return l10n.settingsDashboardUpcomingModeToday;
      case DashboardUpcomingMode.count:
        final int count = int.tryParse(_dashboardCountController.text) ??
            kDefaultDashboardUpcomingCount;
        return l10n.settingsDashboardUpcomingModeCountSummary(count);
    }
  }

  bool get _settingsBusy =>
      _viewModel.settingsLoading || _viewModel.settingsSaving;

  void _onUpcomingModeChanged(DashboardUpcomingMode value) {
    setState(() {
      _draftUpcomingMode = value;
    });
  }

  void _onDashboardCountChanged(String _) {
    if (_draftUpcomingMode != DashboardUpcomingMode.count) {
      return;
    }
    setState(() {});
  }

  Widget _buildMaxWeekCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        title: Text(l10n.settingsMaxWeekTitle),
        subtitle: Text(l10n.settingsMaxWeekSubtitle),
        trailing: SizedBox(
          width: 100,
          child: TextField(
            controller: _maxWeekController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            enabled: !_settingsBusy,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: Text(l10n.settingsTimeSlotsTitle),
        subtitle: Text(_timeSlotSummary(l10n)),
        trailing: const Icon(Icons.chevron_right),
        onTap: _settingsBusy ? null : _openTimeSlotEditor,
      ),
    );
  }

  Widget _buildDashboardUpcomingCard(AppLocalizations l10n) {
    return UpcomingCoursesCard(
      l10n: l10n,
      mode: _draftUpcomingMode,
      countController: _dashboardCountController,
      enabled: !_settingsBusy,
      summaryText: _dashboardUpcomingSummary(l10n),
      onModeChanged: _onUpcomingModeChanged,
      onCountChanged: _onDashboardCountChanged,
    );
  }

  Widget _buildAdvancedSectionTitle(AppLocalizations l10n) {
    return Text(
      l10n.settingsAdvancedSectionTitle,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildResetCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.restore),
        title: Text(l10n.settingsResetTitle),
        subtitle: Text(l10n.settingsResetSubtitle),
        onTap: _settingsBusy ? null : () => _confirmResetSettings(context),
      ),
    );
  }

  Widget _buildDeveloperCard(AppLocalizations l10n) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.developer_mode),
        title: Text(l10n.settingsDeveloperTitle),
        subtitle: Text(l10n.settingsDeveloperSubtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(RoutePaths.homeSettingsDeveloper),
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Center(
      child: FilledButton(
        onPressed: _viewModel.loading ? null : () => _logout(context),
        child: Text(l10n.logOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSettings),
        actions: [
          AnimatedBuilder(
            animation: _viewModel,
            builder: (context, _) => IconButton(
              tooltip: l10n.saveLabel,
              icon: const Icon(Icons.save),
              onPressed: _settingsBusy ? null : _submitSettings,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMaxWeekCard(l10n),
            const SizedBox(height: 12),
            _buildTimeSlotCard(l10n),
            const SizedBox(height: 12),
            _buildDashboardUpcomingCard(l10n),
            const SizedBox(height: 24),
            _buildAdvancedSectionTitle(l10n),
            const SizedBox(height: 8),
            _buildResetCard(l10n),
            const SizedBox(height: 12),
            _buildDeveloperCard(l10n),
            const SizedBox(height: 24),
            _buildLogoutButton(l10n),
          ],
        ),
      ),
    );
  }
}
