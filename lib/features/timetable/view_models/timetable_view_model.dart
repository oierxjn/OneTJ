import 'dart:async';

import 'package:onetj/app/exception/app_exception.dart';
import 'package:onetj/features/timetable/models/timetable_model.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/timetable_index.dart';

enum TimetableDisplayMode {
  day,
  week,
}

class TimetableViewModel extends BaseViewModel {
  TimetableViewModel({
    TimetableModel? model,
    int maxWeek = 22,
  })  : _model = model ?? TimetableModel(),
        _maxWeek = maxWeek,
        _eventController = StreamController<UiEvent>.broadcast();

  final TimetableModel _model;
  final StreamController<UiEvent> _eventController;
  final int _maxWeek;

  TimetableIndex? _index;
  Object? _error;
  bool _isLoading = true;
  int _selectedDay = DateTime.now().weekday;
  int? _currentWeek;
  int? _selectedWeek;
  TimetableDisplayMode _mode = TimetableDisplayMode.day;

  TimetableIndex? get index => _index;
  Object? get error => _error;
  bool get isLoading => _isLoading;
  int get selectedDay => _selectedDay;
  int? get selectedWeek => _selectedWeek;
  TimetableDisplayMode get mode => _mode;
  List<int> get availableWeeks => _availableWeeks();
  Stream<UiEvent> get events => _eventController.stream;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _loadCurrentWeek();
    await _loadTimetable();
    _isLoading = false;
    notifyListeners();
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

  Future<void> _loadCurrentWeek() async {
    try {
      _currentWeek = await _model.getSchoolCalendarCurrentWeek();
    } catch (error) {
      _currentWeek = null;
      _eventController.add(
        ShowSnackBarEvent(message: _formatErrorMessage(error)),
      );
    }
  }

  /// 加载课表索引并同步选中的周数
  /// 
  /// 如果加载失败，将错误存储到 [_error] 中
  Future<void> _loadTimetable() async {
    try {
      _index = await _model.getTimetableIndex();
      _syncSelectedWeek();
    } catch (error) {
      _error = error;
    }
  }

  /// 同步选中的周数
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
    _eventController.close();
    super.dispose();
  }
}
