import 'dart:async';

import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/features/dashboard/models/dashboard_model.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel({
    DashboardModel? model,
    SettingsRepository? settingsRepository,
  })  : _model = model ?? DashboardModel(),
        _settingsRepository =
            settingsRepository ?? SettingsRepository.getInstance(),
        _eventController = StreamController<UiEvent>.broadcast() {
    _settingsSub = _settingsRepository.stream.listen(_handleSettingsChanged);
  }

  final DashboardModel _model;
  final SettingsRepository _settingsRepository;
  final StreamController<UiEvent> _eventController;
  StreamSubscription<SettingsData>? _settingsSub;
  Stream<UiEvent> get events => _eventController.stream;
  String? _departmentName;
  SchoolCalendarData? _calendar;
  List<TimetableEntry> _timetableEntries = const [];
  List<int> _timeSlotStartMinutes =
      List<int>.from(kDefaultTimeSlotStartMinutes);
  Object? _studentError;
  Object? _calendarError;
  Object? _timetableError;
  bool _studentLoading = true;
  bool _calendarLoading = true;
  bool _timetableLoading = true;

  String? get departmentName => _departmentName;
  SchoolCalendarData? get calendar => _calendar;
  List<TimetableEntry> get timetableEntries => _timetableEntries;
  Object? get studentError => _studentError;
  Object? get calendarError => _calendarError;
  Object? get timetableError => _timetableError;
  bool get studentLoading => _studentLoading;
  bool get calendarLoading => _calendarLoading;
  bool get timetableLoading => _timetableLoading;
  List<int> get timeSlotStartMinutes => _timeSlotStartMinutes;
  List<TimetableEntry> get upcomingEntries =>
      _upcomingEntries(now: DateTime.now(), limit: 3);

  Future<void> load() async {
    _studentLoading = true;
    _calendarLoading = true;
    _timetableLoading = true;
    _studentError = null;
    _calendarError = null;
    _timetableError = null;
    notifyListeners();
    await Future.wait([
      loadSettings(),
      loadStudentInfo(),
      loadSchoolCalendar(),
      loadCourseSchedule(),
    ]);
  }

  /// 获取将要到来的课程
  ///
  /// [now] 相对于的时间，一般填当前时间
  /// [limit] 最多返回的课程数量
  List<TimetableEntry> _upcomingEntries({
    required DateTime now,
    int limit = 3,
  }) {
    final int? currentWeek = _calendar?.week;
    if (_timetableEntries.isEmpty || currentWeek == null || limit <= 0) {
      // TODO: 提示用户没有课程
      return const [];
    }
    final int today = now.weekday;
    final List<TimetableEntry> result = [];
    for (int day = today; day <= 7 && result.length < limit; day += 1) {
      final List<TimetableEntry> dayEntries = _timetableEntries
          .where((entry) =>
              entry.dayOfWeek == day && _matchesWeek(entry, currentWeek))
          .toList()
        ..sort((a, b) => a.timeStart.compareTo(b.timeStart));
      if (day == today) {
        dayEntries.removeWhere((entry) => !_isAfterNow(entry, now));
      }
      for (final entry in dayEntries) {
        result.add(entry);
        if (result.length >= limit) {
          break;
        }
      }
    }
    return result;
  }

  bool _matchesWeek(TimetableEntry entry, int currentWeek) {
    if (entry.weeks.isEmpty) {
      return true;
    }
    return entry.weeks.contains(currentWeek);
  }

  bool _isAfterNow(TimetableEntry entry, DateTime now) {
    final int index = entry.timeStart - 1;
    if (index < 0 || index >= _timeSlotStartMinutes.length) {
      return true;
    }
    final int startMinute = _timeSlotStartMinutes[index];
    final int nowMinutes = now.hour * 60 + now.minute;
    return startMinute > nowMinutes;
  }

  Future<void> loadSettings() async {
    try {
      final SettingsData data = await _settingsRepository.getSettings();
      final List<int> nextTimeSlotStartMinutes = List<int>.from(
        data.timeSlotStartMinutes,
      );
      if (_sameTimeSlots(_timeSlotStartMinutes, nextTimeSlotStartMinutes)) {
        return;
      }
      _timeSlotStartMinutes = nextTimeSlotStartMinutes;
      notifyListeners();
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load settings: $error'),
      );
    }
  }

  void _handleSettingsChanged(SettingsData data) {
    final List<int> nextTimeSlotStartMinutes = List<int>.from(
      data.timeSlotStartMinutes,
    );
    if (_sameTimeSlots(_timeSlotStartMinutes, nextTimeSlotStartMinutes)) {
      return;
    }
    _timeSlotStartMinutes = nextTimeSlotStartMinutes;
    notifyListeners();
  }

  bool _sameTimeSlots(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  Future<void> loadStudentInfo() async {
    try {
      final StudentInfoData data = await _model.fetchStudentInfo();
      _departmentName = data.deptName;
      _studentError = null;
    } catch (error) {
      _studentError = error;
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load student info: $error'),
      );
    } finally {
      _studentLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSchoolCalendar() async {
    final SchoolCalendarRepository repo =
        SchoolCalendarRepository.getInstance();
    try {
      final SchoolCalendarData data = await _model.fetchSchoolCalendar();
      await repo.saveSchoolCalendar(data);
      _calendar = data;
      _calendarError = null;
    } catch (error) {
      repo.markFailed(error);
      _calendarError = error;
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load school calendar: $error'),
      );
    } finally {
      _calendarLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseSchedule() async {
    try {
      final CourseScheduleData data = await _model.getCourseSchedule();
      final TimetableIndex index =
          const TimetableIndexBuilder().buildIndex(data);
      final List<TimetableEntry> entries =
          List<TimetableEntry>.from(index.allEntries)
            ..sort((a, b) {
              final int dayA = a.dayOfWeek;
              final int dayB = b.dayOfWeek;
              if (dayA != dayB) {
                return dayA.compareTo(dayB);
              }
              final int startA = a.timeStart;
              final int startB = b.timeStart;
              if (startA != startB) {
                return startA.compareTo(startB);
              }
              final int endA = a.timeEnd;
              final int endB = b.timeEnd;
              return endA.compareTo(endB);
            });
      _timetableEntries = entries;
      _timetableError = null;
    } catch (error) {
      _timetableError = error;
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load timetable: $error'),
      );
    } finally {
      _timetableLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    _eventController.close();
    super.dispose();
  }
}
