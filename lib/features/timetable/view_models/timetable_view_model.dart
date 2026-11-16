import 'dart:async';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/features/timetable/models/event.dart';
import 'package:onetj/features/timetable/application/timetable_data_service.dart';
import 'package:onetj/app/presentation/session_aware_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/models/settings_defaults.dart';
import 'package:onetj/models/time_period_range.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/repo/settings_repository.dart';

enum TimetableDisplayMode {
  day,
  week,
}

class TimetableViewModel extends SessionAwareViewModel<UiEvent> {
  TimetableViewModel({
    required TimetableDataSource dataService,
    required SettingsRepository settingsRepository,
    required super.sessionController,
    int maxWeek = 22,
  })  : _dataService = dataService,
        _settingsRepository = settingsRepository,
        _maxWeek = maxWeek {
    _settingsSub = _settingsRepository.stream.listen(_handleSettingsChanged);
  }

  final TimetableDataSource _dataService;
  final SettingsRepository _settingsRepository;
  StreamSubscription<SettingsData>? _settingsSub;
  int _maxWeek;

  /// 进入游客态时清空内存课表（不清 _isRefreshing/_selectedDay/设置）。
  /// 课表 tab 常驻 IndexedStack，登录后的自动重载由基类监听承担。
  @override
  void clearPersonalData() {
    _index = null;
    _currentWeek = null;
    _selectedWeek = null;
    _lastFetchedAt = null;
    _error = null;
    _isLoading = false;
  }

  TimetableIndex? _index;
  Object? _error;
  bool _isLoading = true;
  bool _isRefreshing = false;
  List<TimePeriodRangeData> _timeSlotRanges = kDefaultTimeSlotRanges;
  int _selectedDay = DateTime.now().weekday;

  /// 本周
  int? _currentWeek;

  /// 滚轮选中周数
  int? _selectedWeek;
  DateTime? _lastFetchedAt;
  TimetableDisplayMode _mode = TimetableDisplayMode.day;

  TimetableIndex? get index => _index;
  Object? get error => _error;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  List<int> get timeSlotStartMinutes =>
      _timeSlotRanges.map((item) => item.startMinutes).toList(growable: false);
  List<TimePeriodRangeData> get timeSlotRanges => _timeSlotRanges;
  int get selectedDay => _selectedDay;
  int? get selectedWeek => _selectedWeek;
  DateTime? get lastFetchedAt => _lastFetchedAt;
  TimetableDisplayMode get mode => _mode;
  List<int> get availableWeeks => _availableWeeks();

  @override
  Future<void> load() => _load(forceRefresh: false);

  /// 登录成功后强刷课表：登出清理可能残留上一账号缓存（issue #64），
  /// 绕过 TTL 重新拉取，用新账号数据覆盖。
  @override
  Future<void> reloadAfterLogin() => _load(forceRefresh: true);

  Future<void> _load({required bool forceRefresh}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _loadSettings();
    if (isGuest) {
      // 游客态：只加载本地设置，课表留空，由视图展示登录引导。
      _isLoading = false;
      notifyListeners();
      return;
    }
    await _loadCurrentWeek();
    await _loadTimetable(forceRefresh: forceRefresh);
    await _loadLastFetchedAt();
    _isLoading = false;
    notifyListeners();
    // 课表加载完成后（此时页面已由 loading 态切换到内容态）再同步滚轮，
    // 避免滚轮尚未挂载到 FixedExtentScrollController 时触发同步导致失败。
    if (_index != null && _index!.allEntries.isNotEmpty) {
      emit(const SyncWheelEvent());
    }
  }

  /// 强制刷新课表
  ///
  /// 绕过缓存 TTL 从服务器拉取最新课表，刷新期间保留旧课表内容展示。
  /// 成功返回 true；刷新中重复调用或初始加载未完成时为 no-op，返回 false。
  /// 失败时旧数据不动，通过 [ShowSnackBarEvent] 提示错误。
  Future<bool> refresh() async {
    if (_isRefreshing || _isLoading || isGuest) {
      return false;
    }
    _isRefreshing = true;
    notifyListeners();
    bool success = false;
    try {
      final TimetableIndex index = await _dataService.refreshTimetableIndex();
      if (isGuest) {
        return false;
      }
      _index = index;
      _syncSelectedWeek();
      await _loadLastFetchedAt();
      success = true;
    } catch (error) {
      emit(ShowSnackBarEvent(message: _formatErrorMessage(error)));
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
    if (success && _index != null && _index!.allEntries.isNotEmpty) {
      emit(const SyncWheelEvent());
    }
    return success;
  }

  void setMode(TimetableDisplayMode mode) {
    if (_mode == mode) {
      return;
    }
    _mode = mode;
    notifyListeners();
  }

  void selectDay(int day) {
    if (_selectedDay == day) {
      return;
    }
    _selectedDay = day;
    notifyListeners();
  }

  void selectWeek(int? week) {
    if (_selectedWeek == week) {
      return;
    }
    _selectedWeek = week;
    notifyListeners();
  }

  void jumpToToday() {
    final int today = DateTime.now().weekday;
    _selectedDay = today;
    final List<int> weeks = _availableWeeks();
    if (_currentWeek != null && weeks.contains(_currentWeek)) {
      _selectedWeek = _currentWeek;
    } else if (weeks.isNotEmpty && _selectedWeek == null) {
      _selectedWeek = weeks.first;
    }
    notifyListeners();
    emit(const SyncWheelEvent());
  }

  /// 处理设置变化
  ///
  /// 当 [_settingsRepository] 中的设置数据发生变化时，调用此方法。
  /// 如果最大周数或时间槽范围发生变化，将更新 [_maxWeek]、[_timeSlotRanges]、[_availableWeeks] 并通知监听器。
  void _handleSettingsChanged(SettingsData data) {
    final int nextMaxWeek = data.maxWeek;
    final List<TimePeriodRangeData> nextTimeSlotRanges =
        List<TimePeriodRangeData>.from(
      data.timeSlotRanges,
    );
    final bool maxWeekChanged = _maxWeek != nextMaxWeek;
    final bool timeSlotChanged =
        !_sameTimeSlotRanges(_timeSlotRanges, nextTimeSlotRanges);
    if (!maxWeekChanged && !timeSlotChanged) {
      return;
    }
    if (maxWeekChanged) {
      _maxWeek = nextMaxWeek;
      _syncSelectedWeek();
      emit(const SyncWheelEvent());
    }
    if (timeSlotChanged) {
      _timeSlotRanges = nextTimeSlotRanges;
    }
    notifyListeners();
  }

  /// 加载设置到内存
  ///
  /// 从 [_settingsRepository] 中加载设置数据。
  /// 如果加载失败，将显示错误消息。
  Future<void> _loadSettings() async {
    try {
      final SettingsData data = await _settingsRepository.getSettings();
      if (_maxWeek != data.maxWeek) {
        _maxWeek = data.maxWeek;
      }
      _timeSlotRanges = List<TimePeriodRangeData>.from(data.timeSlotRanges);
    } catch (error) {
      emit(
        ShowSnackBarEvent(message: _formatErrorMessage(error)),
      );
    }
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

  /// 获取选中周数的指定天的课表条目
  ///
  /// 如果课表索引为空或选中周数为空，返回空列表。
  /// 否则，返回指定天的课表条目列表。
  /// 列表按开始时间升序排序。
  List<TimetableEntry> entriesForSelectedWeekDay(int day) {
    final TimetableIndex? index = _index;
    if (index == null) {
      return const [];
    }
    if (_selectedWeek == null) {
      return const [];
    }
    final Map<int, List<TimetableEntry>>? weekMap =
        index.byWeekThenDay[_selectedWeek];
    final List<TimetableEntry> entries = weekMap?[day] ?? const [];
    final List<TimetableEntry> sorted = List<TimetableEntry>.from(entries);
    sorted.sort((a, b) {
      final int startA = a.timeStart;
      final int startB = b.timeStart;
      if (startA != startB) {
        return startA.compareTo(startB);
      }
      final int endA = a.timeEnd;
      final int endB = b.timeEnd;
      return endA.compareTo(endB);
    });
    return sorted;
  }

  /// 加载当前周数
  ///
  /// 如果加载失败，将当前周数设置为 null 并显示错误消息。
  Future<void> _loadCurrentWeek() async {
    try {
      final int week = await _dataService.getSchoolCalendarCurrentWeek();
      if (isGuest) {
        return;
      }
      _currentWeek = week;
    } catch (error) {
      _currentWeek = null;
      emit(
        ShowSnackBarEvent(message: _formatErrorMessage(error)),
      );
    }
  }

  /// 加载课表索引
  ///
  /// 加载完成后同步选中的周数
  /// 如果加载失败，将错误存储到 [_error] 中
  /// [forceRefresh] 为 true 时绕过缓存 TTL 直接拉取（登录后强刷）。
  Future<void> _loadTimetable({bool forceRefresh = false}) async {
    try {
      final TimetableIndex index = forceRefresh
          ? await _dataService.refreshTimetableIndex()
          : await _dataService.getTimetableIndex();
      if (isGuest) {
        return;
      }
      _index = index;
      _syncSelectedWeek();
    } catch (error) {
      emit(
        ShowSnackBarEvent(message: _formatErrorMessage(error)),
      );
    }
  }

  Future<void> _loadLastFetchedAt() async {
    try {
      final DateTime? fetchedAt = await _dataService.getLastFetchedAt();
      if (isGuest) {
        return;
      }
      _lastFetchedAt = fetchedAt;
    } catch (_) {
      _lastFetchedAt = null;
    }
  }

  /// 跳转到本周
  ///
  /// 如果当前周数在课表索引中，将选中周数设置为当前周数。
  /// 否则，将选中周数设置为第一周。
  void _syncSelectedWeek() {
    final List<int> weeks = _availableWeeks();
    if (weeks.isEmpty) {
      _selectedWeek = null;
      return;
    }
    if (_selectedWeek != null && weeks.contains(_selectedWeek)) {
      return;
    }
    if (_currentWeek != null && weeks.contains(_currentWeek)) {
      _selectedWeek = _currentWeek;
      return;
    }
    _selectedWeek = weeks.first;
  }

  /// 获取渲染的所有周数
  ///
  /// 周数按升序排序。
  List<int> _availableWeeks() {
    if (_maxWeek <= 0) {
      return const [];
    }
    return List<int>.generate(_maxWeek, (index) => index + 1);
  }

  String _formatErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  @override
  void dispose() {
    _settingsSub?.cancel();
    super.dispose();
  }
}
