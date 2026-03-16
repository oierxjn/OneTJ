import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/view_models/settings_view_model.dart';
import 'package:onetj/features/settings/views/widgets/settings_card.dart';
import 'package:onetj/features/settings/views/widgets/settings_card_visual_state.dart';
import 'package:onetj/features/settings/views/widgets/upcoming_courses_card.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/time_slot.dart';
import 'package:onetj/models/user_collection_field.dart';
import 'package:onetj/services/hive_storage_service.dart';

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
        _syncControllersFromViewModel();
        final AppLocalizations l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsSaved)),
        );
        return;
      }
      if (event is SettingsResetEvent) {
        _syncControllersFromViewModel();
        final AppLocalizations l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsResetDone)),
        );
        return;
      }
      if (event is SettingsDataMigrationEvent) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        String message;
        switch (event.result) {
          case HiveDataMigrationResult.success:
            message =
                '${l10n.settingsDataMigrationSuccess} ${l10n.settingsDataMigrationRestartHint}';
            break;
          case HiveDataMigrationResult.noLegacyData:
            message = l10n.settingsDataMigrationNoData;
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }
      if (event is SettingsDataMigrationFailedEvent) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsDataMigrationFailed)),
        );
        return;
      }
      if (event is SettingsDataCleanupEvent) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        final String message = switch (event.result) {
          HiveDataCleanupResult.success => l10n.settingsDataCleanupSuccess,
          HiveDataCleanupResult.noLegacyData => l10n.settingsDataCleanupNoData,
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        return;
      }
      if (event is SettingsDataCleanupFailedEvent) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsDataCleanupFailed)),
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
    await _viewModel.initialize();
    if (!mounted) {
      return;
    }
    _syncControllersFromViewModel();
  }

  void _syncControllersFromViewModel() {
    _syncControllerText(_maxWeekController, _viewModel.draftMaxWeekText);
    _syncControllerText(
      _dashboardCountController,
      _viewModel.draftDashboardUpcomingCountText,
    );
  }

  void _syncControllerText(TextEditingController controller, String next) {
    if (controller.text == next) {
      return;
    }
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  Future<void> _submitSettings() async {
    await _viewModel.saveSettings();
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

  Future<void> _confirmMigrateLegacyData(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsDataMigrationConfirmTitle),
        content: Text(l10n.settingsDataMigrationConfirmBody),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
              await _viewModel.cleanupLegacyHiveData();
            },
            child: Text(l10n.settingsDataCleanupAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await _viewModel.migrateLegacyHiveData();
  }

  Future<void> _onTapDataMigration(BuildContext context) async {
    if (_settingsBusy || _viewModel.hiveMigrationLoading) {
      return;
    }
    if (!_viewModel.hiveMigrationStateLoaded) {
      await _viewModel.loadHiveMigrationState();
    }
    if (!context.mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!_viewModel.legacyHiveDataAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsDataMigrationNoData)),
      );
      return;
    }
    await _confirmMigrateLegacyData(context);
  }

  Future<void> _openTimeSlotEditor() async {
    final List<TimePeriodRangeData>? next =
        await context.push<List<TimePeriodRangeData>>(
      RoutePaths.homeSettingsTimeSlots,
      extra: _viewModel.draftTimeSlotRanges
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
    _viewModel.updateTimeSlotRanges(next);
  }

  Future<void> _openUserCollectionPolicy() async {
    final Set<UserCollectionField>? next =
        await context.push<Set<UserCollectionField>>(
      RoutePaths.homeSettingsUserCollectionPolicy,
      extra:
          Set<UserCollectionField>.from(_viewModel.draftUserCollectionFields),
    );
    if (next == null || !mounted) {
      return;
    }
    _viewModel.updateUserCollectionFields(next);
  }

  Future<void> _showLaunchWallpaperActions(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int? action = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.settingsLaunchWallpaperPickAction),
              onTap: () => Navigator.of(context).pop(1),
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: Text(l10n.settingsLaunchWallpaperResetAction),
              onTap: () => Navigator.of(context).pop(2),
            ),
          ],
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    if (action == 1) {
      await _pickLaunchWallpaper();
      return;
    }
    if (action == 2) {
      _resetLaunchWallpaperToDefault();
    }
  }

  Future<void> _pickLaunchWallpaper() async {
    final bool changed = await _viewModel.pickLaunchWallpaperFromGallery();
    if (!mounted || !changed) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsLaunchWallpaperPickSuccess)),
    );
  }

  void _resetLaunchWallpaperToDefault() {
    _viewModel.resetLaunchWallpaperToDefault();
    final AppLocalizations l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsLaunchWallpaperResetDone)),
    );
  }

  String _timeSlotSummary(AppLocalizations l10n) {
    final List<TimePeriodRangeData> ranges = _viewModel.draftTimeSlotRanges;
    if (ranges.isEmpty) {
      return l10n.settingsTimeSlotsEmpty;
    }
    final String first = TimeSlot.formatMinutes(ranges.first.startMinutes);
    final String last = TimeSlot.formatMinutes(ranges.last.endMinutes);
    return l10n.settingsTimeSlotsSummary(
      ranges.length,
      first,
      last,
    );
  }

  String _dashboardUpcomingSummary(AppLocalizations l10n) {
    switch (_viewModel.draftUpcomingMode) {
      case DashboardUpcomingMode.thisWeek:
        return l10n.settingsDashboardUpcomingModeThisWeek;
      case DashboardUpcomingMode.today:
        return l10n.settingsDashboardUpcomingModeToday;
      case DashboardUpcomingMode.count:
        return l10n.settingsDashboardUpcomingModeCountSummary(
          _viewModel.summaryUpcomingCount,
        );
    }
  }

  String _userCollectionSummary(AppLocalizations l10n) {
    final int selected = _viewModel.draftUserCollectionFields.length;
    return l10n.settingsUserCollectionPolicySummary(
      selected,
      UserCollectionField.values.length,
    );
  }

  String _launchWallpaperSummary(AppLocalizations l10n) {
    if (_viewModel.draftLaunchWallpaperPath == null) {
      return l10n.settingsLaunchWallpaperDefaultSummary;
    }
    return l10n.settingsLaunchWallpaperCustomSummary;
  }

  bool get _settingsBusy => _viewModel.isBusy;

  SettingsCardStatus _resolveCardStatus({
    required bool isDirty,
    required bool hasError,
  }) {
    if (hasError) {
      return SettingsCardStatus.error;
    }
    if (isDirty) {
      return SettingsCardStatus.dirty;
    }
    return SettingsCardStatus.normal;
  }

  void _onUpcomingModeChanged(DashboardUpcomingMode value) {
    _viewModel.updateUpcomingMode(value);
  }

  void _onDashboardCountChanged(String value) {
    _viewModel.updateDashboardUpcomingCountText(value);
  }

  Widget _buildMaxWeekCard(AppLocalizations l10n) {
    final SettingsCardStatus status = _resolveCardStatus(
      isDirty: _viewModel.isMaxWeekDirty,
      hasError: _viewModel.isMaxWeekInvalid,
    );
    return SettingsCard(
      status: status,
      title: Text(l10n.settingsMaxWeekTitle),
      subtitle: Text(l10n.settingsMaxWeekSubtitle),
      trailing: SizedBox(
        width: 100,
        child: TextField(
          controller: _maxWeekController,
          onChanged: _viewModel.updateMaxWeekText,
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
    );
  }

  Widget _buildTimeSlotCard(AppLocalizations l10n) {
    final SettingsCardStatus status = _resolveCardStatus(
      isDirty: _viewModel.isTimeSlotDirty,
      hasError: false,
    );
    return SettingsCard(
      status: status,
      leading: const Icon(Icons.schedule),
      title: Text(l10n.settingsTimeSlotsTitle),
      subtitle: Text(_timeSlotSummary(l10n)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _settingsBusy ? null : _openTimeSlotEditor,
    );
  }

  Widget _buildDashboardUpcomingCard(AppLocalizations l10n) {
    final SettingsCardStatus status = _resolveCardStatus(
      isDirty: _viewModel.isUpcomingDirty,
      hasError: _viewModel.isUpcomingInvalid,
    );
    return UpcomingCoursesCard(
      l10n: l10n,
      mode: _viewModel.draftUpcomingMode,
      countController: _dashboardCountController,
      enabled: !_settingsBusy,
      summaryText: _dashboardUpcomingSummary(l10n),
      onModeChanged: _onUpcomingModeChanged,
      onCountChanged: _onDashboardCountChanged,
      status: status,
    );
  }

  Widget _buildCommonSectionTitle(AppLocalizations l10n) {
    return Text(
      l10n.settingsCommonSectionTitle,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildAdvancedSectionTitle(AppLocalizations l10n) {
    return Text(
      l10n.settingsAdvancedSectionTitle,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildResetCard(AppLocalizations l10n) {
    return SettingsCard(
      leading: const Icon(Icons.restore),
      title: Text(l10n.settingsResetTitle),
      subtitle: Text(l10n.settingsResetSubtitle),
      onTap: _settingsBusy ? null : () => _confirmResetSettings(context),
    );
  }

  Widget _buildDataMigrationCard(AppLocalizations l10n) {
    final bool canTap = !_settingsBusy && !_viewModel.hiveMigrationLoading;
    final String subtitle;
    if (_viewModel.hiveMigrationLoading) {
      subtitle = l10n.settingsDataMigrationLoading;
    } else if (!_viewModel.hiveMigrationStateLoaded) {
      subtitle = l10n.settingsDataMigrationSubtitle;
    } else if (!_viewModel.legacyHiveDataAvailable) {
      subtitle = l10n.settingsDataMigrationNoData;
    } else {
      subtitle = l10n.settingsDataMigrationSubtitle;
    }
    return SettingsCard(
      leading: const Icon(Icons.move_down),
      title: Text(l10n.settingsDataMigrationTitle),
      subtitle: Text(subtitle),
      onTap: canTap ? () => _onTapDataMigration(context) : null,
    );
  }

  Widget _buildDeveloperCard(AppLocalizations l10n) {
    return SettingsCard(
      leading: const Icon(Icons.developer_mode),
      title: Text(l10n.settingsDeveloperTitle),
      subtitle: Text(l10n.settingsDeveloperSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(RoutePaths.homeSettingsDeveloper),
    );
  }

  Widget _buildUserCollectionPolicyCard(AppLocalizations l10n) {
    final SettingsCardStatus status = _resolveCardStatus(
      isDirty: _viewModel.isUserCollectionDirty,
      hasError: false,
    );
    return SettingsCard(
      status: status,
      leading: const Icon(Icons.privacy_tip_outlined),
      title: Text(l10n.settingsUserCollectionPolicyTitle),
      subtitle: Text(_userCollectionSummary(l10n)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _settingsBusy ? null : _openUserCollectionPolicy,
    );
  }

  Widget _buildLaunchWallpaperCard(AppLocalizations l10n) {
    final SettingsCardStatus status = _resolveCardStatus(
      isDirty: _viewModel.isLaunchWallpaperDirty,
      hasError: false,
    );
    return SettingsCard(
      status: status,
      leading: const Icon(Icons.wallpaper_outlined),
      title: Text(l10n.settingsLaunchWallpaperTitle),
      subtitle: Text(_launchWallpaperSummary(l10n)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _settingsBusy ? null : () => _showLaunchWallpaperActions(context),
    );
  }

  Widget _buildAboutCard(AppLocalizations l10n) {
    return SettingsCard(
      leading: const Icon(Icons.info_outline),
      title: Text(l10n.settingsAboutTitle),
      subtitle: Text(l10n.settingsAboutSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(RoutePaths.homeSettingsAbout),
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

  Widget _buildLoadingBody() {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildLoadedBody(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCommonSectionTitle(l10n),
        const SizedBox(height: 8),
        _buildMaxWeekCard(l10n),
        const SizedBox(height: 12),
        _buildTimeSlotCard(l10n),
        const SizedBox(height: 12),
        _buildDashboardUpcomingCard(l10n),
        const SizedBox(height: 12),
        _buildUserCollectionPolicyCard(l10n),
        const SizedBox(height: 12),
        _buildLaunchWallpaperCard(l10n),
        const SizedBox(height: 12),
        _buildAboutCard(l10n),
        const SizedBox(height: 24),
        _buildAdvancedSectionTitle(l10n),
        const SizedBox(height: 8),
        _buildResetCard(l10n),
        const SizedBox(height: 12),
        _buildDataMigrationCard(l10n),
        const SizedBox(height: 12),
        _buildDeveloperCard(l10n),
        const SizedBox(height: 24),
        _buildLogoutButton(l10n),
      ],
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
              onPressed: !_viewModel.uiState.isHydrated || _settingsBusy
                  ? null
                  : _submitSettings,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          if (!_viewModel.uiState.isHydrated) {
            return _buildLoadingBody();
          }
          _syncControllersFromViewModel();
          return _buildLoadedBody(l10n);
        },
      ),
    );
  }
}
