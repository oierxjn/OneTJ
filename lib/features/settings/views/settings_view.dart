import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:onetj/features/home/views/widgets/home_shell_back_button.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/features/home/views/widgets/home_slim_header.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/models/launch_wallpaper_editor_result.dart';
import 'package:onetj/features/settings/view_models/settings_view_model.dart';
import 'package:onetj/features/settings/views/widgets/settings_sections.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/time_slot.dart';
import 'package:onetj/models/user_collection_field.dart';
import 'package:onetj/services/hive_storage_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({required this.viewModel, super.key});

  final SettingsViewModel viewModel;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;
  late final TextEditingController _maxWeekController;
  late final TextEditingController _dashboardCountController;
  late final FocusNode _maxWeekFocusNode;
  late final FocusNode _dashboardCountFocusNode;
  Timer? _successFlashTimer;
  SettingsCardField? _successFlashField;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _maxWeekController = TextEditingController();
    _dashboardCountController = TextEditingController();
    _maxWeekFocusNode = FocusNode();
    _dashboardCountFocusNode = FocusNode();
    _maxWeekFocusNode.addListener(_onMaxWeekFocusChanged);
    _dashboardCountFocusNode.addListener(_onDashboardCountFocusChanged);
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
      if (event is SettingsSavedFeedbackEvent) {
        _successFlashTimer?.cancel();
        setState(() {
          _successFlashField = event.field;
        });
        _successFlashTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _successFlashField = null;
            });
          }
        });
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
    _successFlashTimer?.cancel();
    _maxWeekFocusNode.removeListener(_onMaxWeekFocusChanged);
    _dashboardCountFocusNode.removeListener(_onDashboardCountFocusChanged);
    _maxWeekFocusNode.dispose();
    _dashboardCountFocusNode.dispose();
    _maxWeekController.dispose();
    _dashboardCountController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// 文本框失去焦点即提交草稿。
  ///
  /// Flutter 默认点击文本框外部会先使其失焦，因此切换选项卡、打开
  /// 子编辑器等离开操作都会先经过这里完成落盘。
  void _onMaxWeekFocusChanged() {
    if (!_maxWeekFocusNode.hasFocus) {
      unawaited(_viewModel.commitMaxWeekText());
    }
  }

  void _onDashboardCountFocusChanged() {
    if (!_dashboardCountFocusNode.hasFocus) {
      unawaited(_viewModel.commitDashboardUpcomingCountText());
    }
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

  Future<void> _openLaunchWallpaperEditor() async {
    final LaunchWallpaperEditorResult? result =
        await context.push<LaunchWallpaperEditorResult>(
      RoutePaths.homeSettingsLaunchWallpaper,
      extra: _viewModel.draftLaunchWallpaperRef,
    );
    if (!mounted || result == null) {
      return;
    }
    switch (result.action) {
      case LaunchWallpaperEditorAction.unchanged:
        return;
      case LaunchWallpaperEditorAction.selected:
        _viewModel.updateLaunchWallpaperSelection(result.wallpaperRef);
        return;
    }
  }

  String _timeSlotSummary(AppLocalizations l10n) {
    final List<TimePeriodRangeData> ranges = _viewModel.draftTimeSlotRanges;
    if (ranges.isEmpty) {
      return l10n.settingsTimeSlotsEmpty;
    }
    final String first = TimeSlot.formatMinutes(ranges.first.startMinutes);
    final String last = TimeSlot.formatMinutes(ranges.last.endMinutes);
    return l10n.settingsTimeSlotsSummary(ranges.length, first, last);
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
    return l10n.settingsUserCollectionPolicySummary(
      _viewModel.draftUserCollectionFields.length,
      UserCollectionField.values.length,
    );
  }

  String _launchWallpaperSummary(AppLocalizations l10n) {
    if (_viewModel.draftLaunchWallpaperRef.type ==
        LaunchWallpaperRef.typeBuiltin) {
      return l10n.settingsLaunchWallpaperDefaultSummary;
    }
    return l10n.settingsLaunchWallpaperCustomSummary;
  }

  bool get _settingsBusy => _viewModel.isBusy;

  Widget _buildLoadedBody(AppLocalizations l10n) {
    return SettingsSections(
      l10n: l10n,
      maxWeekController: _maxWeekController,
      dashboardCountController: _dashboardCountController,
      maxWeekFocusNode: _maxWeekFocusNode,
      dashboardCountFocusNode: _dashboardCountFocusNode,
      maxWeekInvalid: _viewModel.isMaxWeekInvalid,
      upcomingInvalid: _viewModel.isUpcomingInvalid,
      visibleSavingField: _viewModel.visibleSavingField,
      successFlashField: _successFlashField,
      timeSlotSummary: _timeSlotSummary(l10n),
      dashboardUpcomingSummary: _dashboardUpcomingSummary(l10n),
      userCollectionSummary: _userCollectionSummary(l10n),
      launchWallpaperSummary: _launchWallpaperSummary(l10n),
      upcomingMode: _viewModel.draftUpcomingMode,
      themeColor: _viewModel.themeColor,
      homeLayout: _viewModel.homeLayout,
      hiveMigrationLoading: _viewModel.hiveMigrationLoading,
      hiveMigrationStateLoaded: _viewModel.hiveMigrationStateLoaded,
      legacyHiveDataAvailable: _viewModel.legacyHiveDataAvailable,
      onMaxWeekChanged: _viewModel.updateMaxWeekText,
      onUpcomingModeChanged: (mode) =>
          unawaited(_viewModel.updateUpcomingMode(mode)),
      onDashboardCountChanged: _viewModel.updateDashboardUpcomingCountText,
      onThemeColorChanged: _viewModel.setThemeColor,
      onHomeLayoutChanged: _viewModel.setHomeLayout,
      onOpenTimeSlotEditor: _openTimeSlotEditor,
      onOpenUserCollectionPolicy: _openUserCollectionPolicy,
      onOpenLaunchWallpaperEditor: _openLaunchWallpaperEditor,
      onOpenCustomColor: () => context.push(RoutePaths.homeSettingsColorPicker),
      onOpenAbout: () => context.push(RoutePaths.homeSettingsAbout),
      onReset: () => _confirmResetSettings(context),
      onTapDataMigration: () => _onTapDataMigration(context),
      onOpenDeveloper: () => context.push(RoutePaths.homeSettingsDeveloper),
      onLogout: () => _logout(context),
      logoutLoading: _viewModel.loading,
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final Widget? homeBackButton = buildHomeShellBackButton(context);
        final Widget body;
        if (!_viewModel.uiState.isHydrated) {
          body = _buildLoadingBody();
        } else {
          _syncControllersFromViewModel();
          body = _buildLoadedBody(l10n);
        }

        return Scaffold(
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                HomeSlimHeader(
                  leading: homeBackButton,
                  title: homeBackButton == null ? null : l10n.tabSettings,
                ),
                Expanded(child: body),
              ],
            ),
          ),
        );
      },
    );
  }
}
