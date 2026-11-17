import 'dart:async';

import 'package:onetj/app/session/session_controller.dart';
import 'package:onetj/features/dashboard/application/dashboard_data_service.dart';
import 'package:onetj/features/dashboard/models/dashboard_upcoming_entry_data.dart';
import 'package:onetj/features/dashboard/models/upcoming_entries_calculator.dart';
import 'package:onetj/app/presentation/session_aware_view_model.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/models/course_schedule_data.dart';
import 'package:onetj/models/school_calendar_data.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/repo/settings_repository.dart';
import 'package:onetj/models/student_info_data.dart';
import 'package:onetj/services/timetable_index_builder.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/auth_token_provider.dart';
import 'package:onetj/app/logging/logger.dart';

class DashboardViewModel extends SessionAwareViewModel<UiEvent> {
  DashboardViewModel({
    required DashboardDataService dataService,
    required SettingsRepository settingsRepository,
    required AppUpdateService appUpdateService,
    required super.sessionController,
  })  : _dataService = dataService,
        _settingsRepository = settingsRepository,
        _appUpdateService = appUpdateService,
        _sessionController = sessionController {
    _settingsSub = _settingsRepository.stream.listen(_listenSettingsChanged);
  }

  final DashboardDataService _dataService;
  final SettingsRepository _settingsRepository;
  final AppUpdateService _appUpdateService;
  final SessionController _sessionController;
  StreamSubscription<SettingsData>? _settingsSub;
  Timer? _upcomingRefreshTimer;
  DateTime? _lastCalendarSyncDate;

  /// 本轮加载是否出现过瞬时失败（#82）。一轮内多个数据源失败只提示一次。
  bool _transientLoadFailed = false;

  /// 当前是否具备联网拉取平台数据的条件。
  ///
  /// 仅已登录态允许联网。失效态（expired）只读缓存（见
  /// [_loadPlatformDataFromCache]），游客态没有令牌，跳过一切鉴权请求，
  /// 避免触发 401 干扰会话状态。
  /// 注意与基类 [isGuest] 不等价：本护栏在 unknown 下也拦截，保留原语义。
  bool get _canFetchPlatformData =>
      _sessionController.status == AuthStatus.authenticated;

  /// 清空内存中的个人数据（学籍/校历/课表），保留本地设置。
  /// 登录恢复重载与游客态清内存的分发由基类监听承担。
  @override
  void clearPersonalData() {
    _departmentName = null;
    _calendar = null;
    _timetableIndex = null;
    _timetableEntries = const [];
    _lastCalendarSyncDate = null;
    _studentLoading = false;
    _calendarLoading = false;
    _timetableLoading = false;
  }

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
  bool _loading = false;

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

  @override
  Future<void> load() async {
    // 并发防护：登录恢复与前台恢复可能同时触发，避免重复拉取/重复检查更新。
    if (_loading) {
      return;
    }
    _loading = true;
    _transientLoadFailed = false;
    _studentLoading = true;
    _calendarLoading = true;
    _timetableLoading = true;
    _upcomingRefreshTimer?.cancel();
    notifyListeners();
    unawaited(_checkUpdateInBackground());
    try {
      if (_sessionController.status == AuthStatus.expired) {
        // 失效态：平台数据只读缓存，绝不联网（#82）。缓存缺失保持空态，
        // 由视图的失效登录引导卡片承载后续动作。
        await Future.wait([
          loadSettings(),
          _loadPlatformDataFromCache(),
        ]);
        notifyListeners();
        return;
      }
      if (!_canFetchPlatformData) {
        // 游客态：只加载本地设置，平台数据留空，由视图展示登录引导。
        clearPersonalData();
        await loadSettings();
        notifyListeners();
        return;
      }
      await Future.wait([
        loadSettings(),
        loadStudentInfo(),
        loadSchoolCalendar(),
        loadCourseSchedule(),
        _uploadUserCollectionWhenStudentInfoLoaded(),
      ]);
      _notifyLoadFailureOnce();
    } finally {
      _loading = false;
      _scheduleUpcomingRefresh();
    }
  }

  /// 失效态只读加载平台缓存（#82）：全程不发起网络请求，缓存缺失保持
  /// 空态；读缓存异常只记日志，不弹提示（失效态已有登录引导卡片）。
  Future<void> _loadPlatformDataFromCache() async {
    try {
      final StudentInfoData? studentInfo =
          await _dataService.loadCachedStudentInfo();
      _departmentName = studentInfo?.deptName;
      final SchoolCalendarData? calendar =
          await _dataService.loadCachedSchoolCalendar();
      _calendar = calendar;
      final CourseScheduleData? schedule =
          await _dataService.loadCachedCourseSchedule();
      if (schedule == null) {
        _timetableIndex = null;
        _timetableEntries = const [];
      } else {
        _applyCourseSchedule(schedule);
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Dashboard cache read failed in expired state',
        loggerName: 'DashboardViewModel',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _studentLoading = false;
      _calendarLoading = false;
      _timetableLoading = false;
    }
  }

  /// 瞬时失败一轮只提示一次（#82）：并发加载器只置标记，由加载入口在
  /// 全部落定后统一发一个语义事件，视图映射为本地化提示。
  void _notifyLoadFailureOnce() {
    if (!_transientLoadFailed) {
      return;
    }
    _transientLoadFailed = false;
    emit(const DashboardLoadFailedEvent());
  }

  Future<void> _checkUpdateInBackground() async {
    try {
      final result = await _appUpdateService.checkForUpdate(force: false);
      if (!result.hasUpdate || result.updateInfo == null) {
        return;
      }
      emit(
        AppUpdateAvailableEvent(updateInfo: result.updateInfo!),
      );
    } catch (error, stackTrace) {
      _appUpdateService.logUpdateFailure(error, stackTrace);
    }
  }

  Future<bool> skipUpdateVersion(String versionTag) async {
    try {
      await _appUpdateService.skipVersion(versionTag);
      return true;
    } catch (error, stackTrace) {
      _appUpdateService.logUpdateFailure(error, stackTrace);
      emit(
        AppUpdateFailedEvent(error: error, stackTrace: stackTrace),
      );
      return false;
    }
  }

  Future<void> loadSettings() async {
    try {
      final SettingsData data = await _settingsRepository.getSettings();
      _handleSettingsChanged(data);
    } catch (error) {
      emit(
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
      final StudentInfoData data = await _dataService.getStudentInfo();
      _departmentName = data.deptName;
    } catch (error, stackTrace) {
      // 凭证失败是预期分支（会话转失效、视图出登录引导），只记日志；
      // 瞬时失败置标记，由加载入口合并为一次提示（#82）。
      final bool credentialFailure = AuthTokenProvider.isCredentialFailure(error);
      AppLogger.warning(
        credentialFailure
            ? 'Student info load failed: credential failure'
            : 'Student info load failed',
        loggerName: 'DashboardViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      if (!credentialFailure) {
        _transientLoadFailed = true;
      }
    } finally {
      _studentLoading = false;
      notifyListeners();
    }
  }

  Future<void> _uploadUserCollectionWhenStudentInfoLoaded() async {
    // 埋点走 getOrFetch，失效态下会发起注定失败的鉴权请求；失效态不联网
    // （#82），直接跳过。
    if (!_canFetchPlatformData) {
      return;
    }
    try {
      await _dataService.uploadUserCollectionForProduction();
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
    try {
      final DateTime now = DateTime.now();
      final SchoolCalendarData data = await _dataService.getSchoolCalendar();
      _calendar = data;
      _lastCalendarSyncDate = now;
    } catch (error, stackTrace) {
      // 凭证失败只记日志；瞬时失败置标记，一轮合并提示一次（#82）。
      final bool credentialFailure = AuthTokenProvider.isCredentialFailure(error);
      AppLogger.warning(
        credentialFailure
            ? 'School calendar load failed: credential failure'
            : 'School calendar load failed',
        loggerName: 'DashboardViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      if (!credentialFailure) {
        _transientLoadFailed = true;
      }
    } finally {
      _calendarLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourseSchedule() async {
    try {
      final CourseScheduleData data = await _dataService.getCourseSchedule();
      _applyCourseSchedule(data);
    } catch (error, stackTrace) {
      _timetableIndex = null;
      // 凭证失败只记日志；瞬时失败置标记，一轮合并提示一次（#82）。
      final bool credentialFailure = AuthTokenProvider.isCredentialFailure(error);
      AppLogger.warning(
        credentialFailure
            ? 'Timetable load failed: credential failure'
            : 'Timetable load failed',
        loggerName: 'DashboardViewModel',
        error: error,
        stackTrace: stackTrace,
      );
      if (!credentialFailure) {
        _transientLoadFailed = true;
      }
    } finally {
      _timetableLoading = false;
      notifyListeners();
    }
  }

  /// 由课表数据构建索引并排序课程条目，供联网与只读缓存两条路径复用。
  void _applyCourseSchedule(CourseScheduleData data) {
    final TimetableIndex index = const TimetableIndexBuilder().buildIndex(data);
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
  }

  Future<void> onAppResumed() async {
    final DateTime now = DateTime.now();
    final bool shouldSyncCalendar = _canFetchPlatformData &&
        (_lastCalendarSyncDate == null ||
            !_isSameDate(_lastCalendarSyncDate!, now));
    if (shouldSyncCalendar) {
      _transientLoadFailed = false;
      await loadSchoolCalendar();
      _notifyLoadFailureOnce();
      _scheduleUpcomingRefresh();
      return;
    }
    notifyListeners();
    _scheduleUpcomingRefresh();
  }

  /// 计划下次即将到来的课程时间刷新
  void _scheduleUpcomingRefresh() {
    if (isDisposed) {
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
    if (isDisposed) {
      return;
    }
    final DateTime now = DateTime.now();
    final bool shouldSyncCalendar = _canFetchPlatformData &&
        (_lastCalendarSyncDate == null ||
            !_isSameDate(_lastCalendarSyncDate!, now));
    if (shouldSyncCalendar) {
      _transientLoadFailed = false;
      await loadSchoolCalendar();
      _notifyLoadFailureOnce();
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
    _upcomingRefreshTimer?.cancel();
    _settingsSub?.cancel();
    super.dispose();
  }
}
