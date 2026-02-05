import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:onetj/app/constant/route_paths.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/token_repository.dart';

class SettingsViewModel extends BaseViewModel {
  SettingsViewModel() : _eventController = StreamController<UiEvent>.broadcast();

  final StreamController<UiEvent> _eventController;
  Stream<UiEvent> get events => _eventController.stream;

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

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
