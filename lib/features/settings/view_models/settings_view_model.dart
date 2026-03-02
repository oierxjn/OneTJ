import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/app/logging/app_logger.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/models/settings_model.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';

class SettingsViewModel extends BaseViewModel {
  SettingsViewModel()
      : _eventController = StreamController<UiEvent>.broadcast();

  final StreamController<UiEvent> _eventController;
  Stream<UiEvent> get events => _eventController.stream;
  // 初值一般不会被使用
  SettingsData _settingsData = SettingsData(
    maxWeek: kDefaultMaxWeek,
    timeSlotRanges: kDefaultTimeSlotRanges,
    dashboardUpcomingMode: kDefaultDashboardUpcomingMode,
    dashboardUpcomingCount: kDefaultDashboardUpcomingCount,
  );
  bool _settingsLoading = true;
  bool _settingsSaving = false;

  int get maxWeek => _settingsData.maxWeek;
  SettingsData get settingsData => _settingsData;
  bool get settingsLoading => _settingsLoading;
  bool get settingsSaving => _settingsSaving;

  Future<void> logout() async {
    AppLogger.logUiAction(feature: 'Settings', action: 'logout_started');
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await TokenRepository.getInstance().clearToken();
      await StudentInfoRepository.getInstance().clearStudentInfo();
      await SchoolCalendarRepository.getInstance().clearSchoolCalendar();
      await CourseScheduleRepository.getInstance().clearCourseSchedule();
      await CookieManager.instance().deleteAllCookies();
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

  Future<void> loadSettings() async {
    AppLogger.info(
      'Load settings started',
      loggerName: 'SettingsViewModel',
    );
    _settingsLoading = true;
    notifyListeners();
    try {
      final SettingsData data =
          await SettingsRepository.getInstance().getSettings();
      _settingsData = data;
      AppLogger.info(
        'Load settings success',
        loggerName: 'SettingsViewModel',
        context: <String, Object?>{
          'maxWeek': data.maxWeek,
          'timeSlotCount': data.timeSlotRanges.length,
        },
      );
    } catch (error) {
      AppLogger.error(
        'Load settings failed',
        loggerName: 'SettingsViewModel',
        error: error,
      );
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load settings: $error'),
      );
    } finally {
      _settingsLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings({
    required String maxWeekText,
    required List<TimePeriodRangeData> editedTimeSlotRanges,
    required DashboardUpcomingMode dashboardUpcomingMode,
    required String dashboardUpcomingCountText,
  }) async {
    AppLogger.logUiAction(feature: 'Settings', action: 'save_started');
    _settingsSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final int maxWeek = SettingsModel.parseMaxWeekText(maxWeekText);
      final int dashboardUpcomingCount =
          dashboardUpcomingMode == DashboardUpcomingMode.count
              ? SettingsModel.parseDashboardUpcomingCountText(
                  dashboardUpcomingCountText,
                )
              : _settingsData.dashboardUpcomingCount;
      SettingsModel.validateMaxWeek(maxWeek);
      SettingsModel.validateTimeSlotRanges(editedTimeSlotRanges);
      SettingsModel.validateDashboardUpcomingCount(dashboardUpcomingCount);
      final SettingsData next = SettingsData(
        maxWeek: maxWeek,
        timeSlotRanges: List<TimePeriodRangeData>.unmodifiable(
          editedTimeSlotRanges,
        ),
        dashboardUpcomingMode: dashboardUpcomingMode,
        dashboardUpcomingCount: dashboardUpcomingCount,
      );
      await SettingsRepository.getInstance().saveSettings(next);
      _settingsData = next;
      AppLogger.info(
        'Save settings success',
        loggerName: 'SettingsViewModel',
        context: <String, Object?>{
          'maxWeek': maxWeek,
          'timeSlotCount': editedTimeSlotRanges.length,
          'dashboardUpcomingMode': dashboardUpcomingMode.jsonValue,
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
      final SettingsRepository repo = SettingsRepository.getInstance();
      await repo.clearSettings();
      _settingsData = await repo.getSettings(refreshFromStorage: true);
      AppLogger.info(
        'Reset settings success',
        loggerName: 'SettingsViewModel',
        context: <String, Object?>{
          'maxWeek': _settingsData.maxWeek,
          'timeSlotCount': _settingsData.timeSlotRanges.length,
        },
      );
      _eventController.add(SettingsResetEvent(settings: _settingsData));
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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
