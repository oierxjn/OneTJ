import 'dart:async';

import 'package:onetj/features/dashboard/models/dashboard_model.dart';
import 'package:onetj/features/dashboard/models/upcoming_entries_calculator.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/course_schedule_repository.dart';
import 'package:onetj/repo/school_calendar_repository.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/repo/student_info_repository.dart';
import 'package:onetj/services/timetable_index_builder.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/user_collection_service.dart';
import 'package:onetj/app/logging/logger.dart';

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel({
    DashboardModel? model,
    SettingsRepository? settingsRepository,
    UserCollectionService? userCollectionService,
  })  : _model = model ?? DashboardModel(),
        _settingsRepository =
            settingsRepository ?? SettingsRepository.getInstance(),
        _userCollectionService =
            userCollectionService ?? UserCollectionService(),
        _eventController = StreamController<UiEvent>.broadcast() {
    _settingsSub = _settingsRepository.stream.listen(_listenSettingsChanged);
  }

  final DashboardModel _model;
  final SettingsRepository _settingsRepository;
  final UserCollectionService _userCollectionService;
  final AppUpdateService _appUpdateService = AppUpdateService.getInstance();
  final StreamController<UiEvent> _eventController;
  StreamSubscription<SettingsData>? _settingsSub;
  Timer? _upcomingRefreshTimer;
  DateTime? _lastCalendarSyncDate;
  bool _isDisposed = false;
  Stream<UiEvent> get events => _eventController.stream;
  bool get isDisposed => _isDisposed;

  String? _departmentName;
  SchoolCalendarData? _calendar;
  TimetableIndex? _timetableIndex;
  List<TimetableEntry> _timetableEntries = const [];
  List<TimePeriodRangeData> _timeSlotRanges = kDefaultTimeSlotRanges;
  DashboardUpcomingMode _upcomingMode = kDefaultDashboardUpcomingMode;
  int _upcomingCount = kDefaultDashboardUpcomingCount;
  int _maxWeek = kDefaultMaxWeek;

  bool _studentLoading = true;
  bool _calendarLoading = true;
  bool _timetableLoading = true;

  String? get departmentName => _departmentName;
  SchoolCalendarData? get calendar => _calendar;
  TimetableIndex? get timetableIndex => _timetableIndex;
  List<TimetableEntry> get timetableEntries => _timetableEntries;
  bool get studentLoading => _studentLoading;
  bool get calendarLoading => _calendarLoading;
  bool get timetableLoading => _timetableLoading;
  List<TimePeriodRangeData> get timeSlotRanges => _timeSlotRanges;
  DashboardUpcomingMode get upcomingMode => _upcomingMode;
  List<DashboardUpcomingEntryData> buildUpcomingEntries({DateTime? now}) {
    final int? currentWeek = _calendar?.week;
    if (currentWeek == null || _timetableEntries.isEmpty) {
      return const [];
    }
    final DateTime clock = now ?? DateTime.now();
    return UpcomingEntriesCalculator.calculate(
      UpcomingEntriesQuery(
        now: clock,
        entries: _timetableEntries,
        timeSlotRanges: _timeSlotRanges,
        currentWeek: currentWeek,
        maxWeek: _maxWeek,
        mode: _upcomingMode,
        count: _upcomingCount,
      ),
    );
  }

  Future<void> load() async {
    _studentLoading = true;
    _calendarLoading = true;
    _timetableLoading = true;
    _upcomingRefreshTimer?.cancel();
    notifyListeners();
    unawaited(_checkUpdateInBackground());
    try {
      await Future.wait([
        loadSettings(),
        loadStudentInfo(),
        loadSchoolCalendar(),
        loadCourseSchedule(),
        _uploadUserCollectionWhenStudentInfoLoaded(),
      ]);
    } finally {
      _scheduleUpcomingRefresh();
    }
  }

  Future<void> _checkUpdateInBackground() async {
    try {
      final result = await _appUpdateService.checkForUpdate(force: false);
      if (!result.hasUpdate || result.updateInfo == null) {
        return;
      }
      _eventController.add(
        AppUpdateAvailableEvent(updateInfo: result.updateInfo!),
      );
    } catch (error, stackTrace) {
      _appUpdateService.logUpdateFailure(error, stackTrace);
    }
  }

  Future<void> loadSettings() async {
    try {
      final SettingsData data = await _settingsRepository.getSettings();
      _handleSettingsChanged(data);
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load settings: $error'),
      );
    }
  }

  void _listenSettingsChanged(SettingsData data) {
    _handleSettingsChanged(data);
    _scheduleUpcomingRefresh();
  }

  void _handleSettingsChanged(SettingsData data) {
    final List<TimePeriodRangeData> nextTimeSlotRanges =
        List<TimePeriodRangeData>.from(data.timeSlotRanges);
    final bool timeSlotChanged =
        !_sameTimeSlotRanges(_timeSlotRanges, nextTimeSlotRanges);
    final bool modeChanged = _upcomingMode != data.dashboardUpcomingMode;
    final bool countChanged = _upcomingCount != data.dashboardUpcomingCount;
    final bool maxWeekChanged = _maxWeek != data.maxWeek;

    if (!timeSlotChanged && !modeChanged && !countChanged && !maxWeekChanged) {
      return;
    }
    if (timeSlotChanged) {
      _timeSlotRanges = nextTimeSlotRanges;
    }
    if (modeChanged) {
      _upcomingMode = data.dashboardUpcomingMode;
    }
    if (countChanged) {
      _upcomingCount = data.dashboardUpcomingCount;
    }
    if (maxWeekChanged) {
      _maxWeek = data.maxWeek;
    }
    notifyListeners();
  }

  bool _sameTimeSlotRanges(
      List<TimePeriodRangeData> a, List<TimePeriodRangeData> b) {
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

  Future<void> loadStudentInfo() async {
    try {
      final StudentInfoData data = await _model.getStudentInfo();
      _departmentName = data.deptName;
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load student info: $error'),
      );
    } finally {
      _studentLoading = false;
      notifyListeners();
    }
  }

  Future<void> _uploadUserCollectionWhenStudentInfoLoaded() async {
    try {
      final StudentInfoRepository repo = StudentInfoRepository.getInstance();
      final StudentInfoData studentInfo = await repo.getOrFetch(
        now: DateTime.now(),
        fetcher: _model.fetchStudentInfo,
        ttl: const Duration(days: 1),
      );
      final SettingsData settings = await _settingsRepository.getSettings();
      await _userCollectionService.uploadForProduction(
        studentInfo: studentInfo,
        settings: settings,
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Dashboard user collection upload failed',
        loggerName: 'DashboardViewModel',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> loadSchoolCalendar() async {
    final SchoolCalendarRepository repo =
        SchoolCalendarRepository.getInstance();
    try {
      final DateTime now = DateTime.now();
      await repo.warmUp();
      final SchoolCalendarData data = await repo.getOrFetch(
        now: now,
        fetcher: _model.fetchSchoolCalendar,
      );
      _calendar = data;
      _lastCalendarSyncDate = now;
    } catch (error) {
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
      _timetableIndex = index;
    } catch (error) {
      _timetableIndex = null;
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load timetable: $error'),
      );
    } finally {
      _timetableLoading = false;
      notifyListeners();
    }
  }

  Future<void> onAppResumed() async {
    final DateTime now = DateTime.now();
    final bool shouldSyncCalendar = _lastCalendarSyncDate == null ||
        !_isSameDate(_lastCalendarSyncDate!, now);
    if (shouldSyncCalendar) {
      await loadSchoolCalendar();
      _scheduleUpcomingRefresh();
      return;
    }
    notifyListeners();
    _scheduleUpcomingRefresh();
  }

  /// 计划下次即将到来的课程时间刷新
  void _scheduleUpcomingRefresh() {
    if (_isDisposed) {
      return;
    }
    _upcomingRefreshTimer?.cancel();
    final DateTime now = DateTime.now();
    final DateTime nextRefreshAt = _computeNextUpcomingRefreshAt(now);
    Duration delay = nextRefreshAt.difference(now);
    if (delay.isNegative) {
      delay = Duration.zero;
    }
    _upcomingRefreshTimer = Timer(delay, () {
      unawaited(_onUpcomingRefreshTick());
    });
  }

  /// 刷新即将到来的课程时间
  Future<void> _onUpcomingRefreshTick() async {
    if (_isDisposed) {
      return;
    }
    final DateTime now = DateTime.now();
    final bool shouldSyncCalendar = _lastCalendarSyncDate == null ||
        !_isSameDate(_lastCalendarSyncDate!, now);
    if (shouldSyncCalendar) {
      await loadSchoolCalendar();
      _scheduleUpcomingRefresh();
      return;
    }
    notifyListeners();
    _scheduleUpcomingRefresh();
  }

  /// 计算下次即将到来的课程时间刷新时间
  DateTime _computeNextUpcomingRefreshAt(DateTime now) {
    final DateTime nextDayStart = DateTime(now.year, now.month, now.day + 1);
    final int? currentWeek = _calendar?.week;
    if (currentWeek == null || _timetableEntries.isEmpty) {
      return nextDayStart;
    }
    final List<DateTime> candidates = <DateTime>[nextDayStart];
    for (final TimetableEntry entry in _timetableEntries) {
      if (entry.dayOfWeek != now.weekday) {
        continue;
      }
      if (entry.weeks.isNotEmpty && !entry.weeks.contains(currentWeek)) {
        continue;
      }
      final int startIndex = entry.timeStart - 1;
      if (startIndex >= 0 && startIndex < _timeSlotRanges.length) {
        final DateTime startTime =
            _atMinuteOfDay(now, _timeSlotRanges[startIndex].startMinutes);
        if (startTime.isAfter(now)) {
          candidates.add(startTime);
        }
      }
      final int endIndex = entry.timeEnd - 1;
      if (endIndex >= 0 && endIndex < _timeSlotRanges.length) {
        final DateTime endTime =
            _atMinuteOfDay(now, _timeSlotRanges[endIndex].endMinutes);
        if (endTime.isAfter(now)) {
          candidates.add(endTime);
        }
      }
    }
    candidates.sort((a, b) => a.compareTo(b));
    return candidates.first;
  }

  DateTime _atMinuteOfDay(DateTime source, int minutes) {
    return DateTime(
      source.year,
      source.month,
      source.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _upcomingRefreshTimer?.cancel();
    _settingsSub?.cancel();
    _eventController.close();
    super.dispose();
  }
}
