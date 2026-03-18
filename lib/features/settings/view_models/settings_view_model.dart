import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/models/user_collection_field.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/models/settings_model.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';
import 'package:onetj/services/hive_storage_service.dart';
import 'package:onetj/services/webview_environment_service.dart';

class SettingsUiState {
  const SettingsUiState({
    required this.isHydrated,
    required this.isLoading,
    required this.isSaving,
  });

  final bool isHydrated;
  final bool isLoading;
  final bool isSaving;
}

class SettingsViewModel extends BaseViewModel {
  SettingsViewModel({
    SettingsRepository? settingsRepository,
  })  : _eventController = StreamController<UiEvent>.broadcast(),
        _settingsRepository =
            settingsRepository ?? SettingsRepository.getInstance(),
        _hiveStorageService = HiveStorageService(),
        _webViewEnvironment = WebViewEnvironmentService.instance.environment {
    _savedSettings = _settingsRepository.peekCachedOrDefault();
    _applySavedToDraft(_savedSettings);
  }

  final StreamController<UiEvent> _eventController;
  final SettingsRepository _settingsRepository;
  final HiveStorageService _hiveStorageService;
  final WebViewEnvironment? _webViewEnvironment;

  late SettingsData _savedSettings;
  late String _draftMaxWeekText;
  late List<TimePeriodRangeData> _draftTimeSlotRanges;
  late DashboardUpcomingMode _draftUpcomingMode;
  late String _draftDashboardUpcomingCountText;
  late Set<UserCollectionField> _draftUserCollectionFields;
  late LaunchWallpaperRef _draftLaunchWallpaperRef;

  bool _hydrated = false;
  bool _settingsLoading = false;
  bool _settingsSaving = false;
  bool _legacyHiveDataAvailable = false;
  bool _hiveMigrationLoading = false;
  bool _hiveMigrationStateLoaded = false;

  Stream<UiEvent> get events => _eventController.stream;

  SettingsUiState get uiState => SettingsUiState(
        isHydrated: _hydrated,
        isLoading: _settingsLoading,
        isSaving: _settingsSaving,
      );

  SettingsData get settingsData => _savedSettings;
  String get draftMaxWeekText => _draftMaxWeekText;
  List<TimePeriodRangeData> get draftTimeSlotRanges =>
      List<TimePeriodRangeData>.unmodifiable(_draftTimeSlotRanges);
  DashboardUpcomingMode get draftUpcomingMode => _draftUpcomingMode;
  String get draftDashboardUpcomingCountText =>
      _draftDashboardUpcomingCountText;
  Set<UserCollectionField> get draftUserCollectionFields =>
      Set<UserCollectionField>.unmodifiable(_draftUserCollectionFields);
  LaunchWallpaperRef get draftLaunchWallpaperRef => _draftLaunchWallpaperRef;

  bool get isHydrated => _hydrated;
  bool get settingsLoading => _settingsLoading;
  bool get settingsSaving => _settingsSaving;
  bool get legacyHiveDataAvailable => _legacyHiveDataAvailable;
  bool get hiveMigrationLoading => _hiveMigrationLoading;
  bool get hiveMigrationStateLoaded => _hiveMigrationStateLoaded;

  bool get isBusy => _settingsLoading || _settingsSaving;

  bool get isMaxWeekDirty =>
      _draftMaxWeekText != _savedSettings.maxWeek.toString();

  bool get isTimeSlotDirty =>
      !_sameTimeSlotRanges(_savedSettings.timeSlotRanges, _draftTimeSlotRanges);

  bool get isUpcomingDirty {
    if (_draftUpcomingMode != _savedSettings.dashboardUpcomingMode) {
      return true;
    }
    if (_draftUpcomingMode != DashboardUpcomingMode.count) {
      return false;
    }
    final int? count = int.tryParse(_draftDashboardUpcomingCountText);
    return count != _savedSettings.dashboardUpcomingCount;
  }

  bool get isUserCollectionDirty {
    final Set<UserCollectionField> saved = _savedSettings.userCollectionFields;
    if (saved.length != _draftUserCollectionFields.length) {
      return true;
    }
    for (final UserCollectionField field in saved) {
      if (!_draftUserCollectionFields.contains(field)) {
        return true;
      }
    }
    return false;
  }

  bool get isLaunchWallpaperDirty =>
      _draftLaunchWallpaperRef != _savedSettings.selectedLaunchWallpaperRef;

  bool get isMaxWeekInvalid {
    try {
      final int maxWeek = SettingsModel.parseMaxWeekText(_draftMaxWeekText);
      SettingsModel.validateMaxWeek(maxWeek);
      return false;
    } on SettingsValidationException {
      return true;
    }
  }

  bool get isUpcomingInvalid {
    if (_draftUpcomingMode != DashboardUpcomingMode.count) {
      return false;
    }
    try {
      final int count = SettingsModel.parseDashboardUpcomingCountText(
        _draftDashboardUpcomingCountText,
      );
      SettingsModel.validateDashboardUpcomingCount(count);
      return false;
    } on SettingsValidationException {
      return true;
    }
  }

  int get summaryUpcomingCount {
    return int.tryParse(_draftDashboardUpcomingCountText) ??
        kDefaultDashboardUpcomingCount;
  }

  Future<void> initialize() async {
    if (_hydrated || _settingsLoading) {
      return;
    }
    AppLogger.info(
      'Initialize settings page state started',
      loggerName: 'SettingsViewModel',
    );
    _settingsLoading = true;
    notifyListeners();
    try {
      final SettingsData data = await _settingsRepository.getSettings();
      _savedSettings = data;
      _applySavedToDraft(data);
      _hydrated = true;
      AppLogger.info(
        'Initialize settings page state success',
        loggerName: 'SettingsViewModel',
        context: <String, Object?>{
          'maxWeek': data.maxWeek,
          'timeSlotCount': data.timeSlotRanges.length,
        },
      );
    } catch (error) {
      AppLogger.error(
        'Initialize settings page state failed',
        loggerName: 'SettingsViewModel',
        error: error,
      );
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load settings: $error'),
      );
      _hydrated = true;
    } finally {
      _settingsLoading = false;
      notifyListeners();
    }
  }

  void updateMaxWeekText(String value) {
    if (_draftMaxWeekText == value) {
      return;
    }
    _draftMaxWeekText = value;
    notifyListeners();
  }

  void updateUpcomingMode(DashboardUpcomingMode mode) {
    if (_draftUpcomingMode == mode) {
      return;
    }
    _draftUpcomingMode = mode;
    notifyListeners();
  }

  void updateDashboardUpcomingCountText(String value) {
    if (_draftDashboardUpcomingCountText == value) {
      return;
    }
    _draftDashboardUpcomingCountText = value;
    notifyListeners();
  }

  void updateTimeSlotRanges(List<TimePeriodRangeData> value) {
    _draftTimeSlotRanges = value
        .map(
          (item) => TimePeriodRangeData(
            startMinutes: item.startMinutes,
            endMinutes: item.endMinutes,
          ),
        )
        .toList(growable: false);
    notifyListeners();
  }

  void updateUserCollectionFields(Set<UserCollectionField> value) {
    _draftUserCollectionFields = Set<UserCollectionField>.from(value);
    notifyListeners();
  }

  void updateLaunchWallpaperSelection(LaunchWallpaperRef value) {
    if (_draftLaunchWallpaperRef == value) {
      return;
    }
    _draftLaunchWallpaperRef = value;
    notifyListeners();
  }

  Future<void> logout() async {
    AppLogger.logUiAction(feature: 'Settings', action: 'logout_started');
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await TokenRepository.getInstance().clearToken();
      await StudentInfoRepository.getInstance().clearCache();
      await SchoolCalendarRepository.getInstance().clearCache();
      await CourseScheduleRepository.getInstance().clearCache();
      await CookieManager.instance(webViewEnvironment: _webViewEnvironment)
          .deleteAllCookies();
      AppLogger.logNavigation(
        from: RoutePaths.homeSettings,
        to: RoutePaths.login,
        context: const <String, Object?>{'reason': 'logout'},
      );
      _eventController.add(const NavigateEvent(RoutePaths.login));
    } catch (error) {
      final String message = 'Failed to log out: $error';
      errorMessage = message;
      AppLogger.error(
        'Logout failed',
        loggerName: 'SettingsViewModel',
        error: error,
      );
      _eventController.add(ShowSnackBarEvent(message: message));
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadHiveMigrationState() async {
    _hiveMigrationLoading = true;
    notifyListeners();
    try {
      _legacyHiveDataAvailable = await _hiveStorageService.hasLegacyHiveData();
      _hiveMigrationStateLoaded = true;
    } catch (error) {
      AppLogger.error(
        'Load hive migration state failed',
        loggerName: 'SettingsViewModel',
        error: error,
      );
    } finally {
      _hiveMigrationLoading = false;
      notifyListeners();
    }
  }

  Future<void> migrateLegacyHiveData() async {
    if (_hiveMigrationLoading) {
      return;
    }
    _hiveMigrationLoading = true;
    notifyListeners();
    try {
      final HiveDataMigrationResult result =
          await _hiveStorageService.migrateLegacyToNew();
      _hiveMigrationStateLoaded = true;
      if (result == HiveDataMigrationResult.success) {
        _legacyHiveDataAvailable = false;
      }
      _eventController.add(SettingsDataMigrationEvent(result: result));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Migrate legacy hive data failed',
        loggerName: 'SettingsViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      _eventController.add(
        const SettingsDataMigrationFailedEvent(),
      );
    } finally {
      _hiveMigrationLoading = false;
      notifyListeners();
    }
  }

  Future<void> cleanupLegacyHiveData() async {
    if (_hiveMigrationLoading) {
      return;
    }
    _hiveMigrationLoading = true;
    notifyListeners();
    try {
      final HiveDataCleanupResult result =
          await _hiveStorageService.cleanupLegacyHiveData();
      _hiveMigrationStateLoaded = true;
      _legacyHiveDataAvailable = false;
      AppLogger.info(
        'Cleanup legacy hive data finished',
        loggerName: 'SettingsViewModel',
        context: <String, Object?>{'result': result.name},
      );
      _eventController.add(SettingsDataCleanupEvent(result: result));
    } catch (error, stackTrace) {
      AppLogger.error(
        'Cleanup legacy hive data failed',
        loggerName: 'SettingsViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      _eventController.add(const SettingsDataCleanupFailedEvent());
    } finally {
      _hiveMigrationLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings() async {
    AppLogger.logUiAction(feature: 'Settings', action: 'save_started');
    _settingsSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final int maxWeek = SettingsModel.parseMaxWeekText(_draftMaxWeekText);
      final int dashboardUpcomingCount =
          _draftUpcomingMode == DashboardUpcomingMode.count
              ? SettingsModel.parseDashboardUpcomingCountText(
                  _draftDashboardUpcomingCountText,
                )
              : _savedSettings.dashboardUpcomingCount;
      SettingsModel.validateMaxWeek(maxWeek);
      SettingsModel.validateTimeSlotRanges(_draftTimeSlotRanges);
      SettingsModel.validateDashboardUpcomingCount(dashboardUpcomingCount);
      final SettingsData next = SettingsData(
        maxWeek: maxWeek,
        timeSlotRanges: List<TimePeriodRangeData>.unmodifiable(
          _draftTimeSlotRanges,
        ),
        dashboardUpcomingMode: _draftUpcomingMode,
        dashboardUpcomingCount: dashboardUpcomingCount,
        userCollectionFields: Set<UserCollectionField>.unmodifiable(
          _draftUserCollectionFields,
        ),
        selectedLaunchWallpaperRef: _draftLaunchWallpaperRef,
      );
      await _settingsRepository.saveSettings(next);
      _savedSettings = next;
      _applySavedToDraft(next);
      AppLogger.info(
        'Save settings success',
        loggerName: 'SettingsViewModel',
        context: <String, Object?>{
          'maxWeek': maxWeek,
          'timeSlotCount': _draftTimeSlotRanges.length,
          'dashboardUpcomingMode': _draftUpcomingMode.jsonValue,
          'dashboardUpcomingCount': dashboardUpcomingCount,
        },
      );
      notifyListeners();
      _eventController.add(SettingsSavedEvent(settings: next));
    } on SettingsValidationException catch (error) {
      errorMessage = error.message;
      AppLogger.warning(
        'Save settings validation failed',
        loggerName: 'SettingsViewModel',
        code: error.code,
        error: error,
      );
      _eventController.add(
        ShowSnackBarEvent(message: error.message, code: error.code),
      );
    } catch (error) {
      final String message = 'Failed to save settings: ${error.toString()}';
      errorMessage = message;
      AppLogger.error(
        'Save settings failed',
        loggerName: 'SettingsViewModel',
        error: error,
      );
      _eventController.add(ShowSnackBarEvent(message: message));
    } finally {
      _settingsSaving = false;
      notifyListeners();
    }
  }

  Future<void> resetSettings() async {
    AppLogger.logUiAction(feature: 'Settings', action: 'reset_started');
    _settingsSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _settingsRepository.clearSettings();
      final SettingsData next =
          await _settingsRepository.getSettings(refreshFromStorage: true);
      _savedSettings = next;
      _applySavedToDraft(next);
      AppLogger.info(
        'Reset settings success',
        loggerName: 'SettingsViewModel',
        context: <String, Object?>{
          'maxWeek': next.maxWeek,
          'timeSlotCount': next.timeSlotRanges.length,
        },
      );
      _eventController.add(SettingsResetEvent(settings: next));
    } catch (error) {
      final String message = 'Failed to reset settings: $error';
      errorMessage = message;
      AppLogger.error(
        'Reset settings failed',
        loggerName: 'SettingsViewModel',
        error: error,
      );
      _eventController.add(ShowSnackBarEvent(message: message));
    } finally {
      _settingsSaving = false;
      notifyListeners();
    }
  }

  void _applySavedToDraft(SettingsData data) {
    _draftMaxWeekText = data.maxWeek.toString();
    _draftTimeSlotRanges = data.timeSlotRanges
        .map(
          (item) => TimePeriodRangeData(
            startMinutes: item.startMinutes,
            endMinutes: item.endMinutes,
          ),
        )
        .toList(growable: false);
    _draftUpcomingMode = data.dashboardUpcomingMode;
    _draftDashboardUpcomingCountText = data.dashboardUpcomingCount.toString();
    _draftUserCollectionFields = Set<UserCollectionField>.from(
      data.userCollectionFields,
    );
    _draftLaunchWallpaperRef = data.selectedLaunchWallpaperRef;
  }

  bool _sameTimeSlotRanges(
    List<TimePeriodRangeData> a,
    List<TimePeriodRangeData> b,
  ) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i += 1) {
      if (a[i].startMinutes != b[i].startMinutes ||
          a[i].endMinutes != b[i].endMinutes) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
