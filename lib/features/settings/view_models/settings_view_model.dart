import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';

class SettingsViewModel extends BaseViewModel {
  SettingsViewModel() : _eventController = StreamController<UiEvent>.broadcast();

  final StreamController<UiEvent> _eventController;
  Stream<UiEvent> get events => _eventController.stream;
  // 初值一般不会被使用
  SettingsData _settingsData = SettingsData(maxWeek: 22);
  bool _settingsLoading = true;
  bool _settingsSaving = false;

  int get maxWeek => _settingsData.maxWeek;
  bool get settingsLoading => _settingsLoading;
  bool get settingsSaving => _settingsSaving;

  Future<void> logout() async {
    loading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await TokenRepository.getInstance().clearToken();
      await StudentInfoRepository.getInstance().clearStudentInfo();
      await SchoolCalendarRepository.getInstance().clearSchoolCalendar();
      await CourseScheduleRepository.getInstance().clearCourseSchedule();
      await CookieManager.instance().deleteAllCookies();
      _eventController.add(const NavigateEvent(RoutePaths.login));
    } catch (error) {
      final String message = 'Failed to log out: $error';
      errorMessage = message;
      _eventController.add(ShowSnackBarEvent(message: message));
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadSettings() async {
    _settingsLoading = true;
    notifyListeners();
    try {
      final SettingsData data = await SettingsRepository.getInstance().getSettings();
      _settingsData = data;
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load settings: $error'),
      );
    } finally {
      _settingsLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(int maxWeek) async {
    _settingsSaving = true;
    errorMessage = null;
    _settingsData = SettingsData(maxWeek: maxWeek);
    notifyListeners();
    try {
      await SettingsRepository.getInstance().saveSettings(
        SettingsData(maxWeek: maxWeek),
      );
      _eventController.add(SettingsSavedEvent(maxWeek: maxWeek));
    } catch (error) {
      final String message = 'Failed to save settings: $error';
      errorMessage = message;
      _eventController.add(ShowSnackBarEvent(message: message));
    } finally {
      _settingsSaving = false;
      notifyListeners();
    }
  }

  Future<void> resetSettings() async {
    _settingsSaving = true;
    errorMessage = null;
    notifyListeners();
    try {
      final SettingsRepository repo = SettingsRepository.getInstance();
      await repo.clearSettings();
      _settingsData = await repo.getSettings(refreshFromStorage: true);
      _eventController.add(SettingsResetEvent(settings: _settingsData));
    } catch (error) {
      final String message = 'Failed to reset settings: $error';
      errorMessage = message;
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
