import 'package:onetj/features/timetable/models/timetable_model.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/timetable_index.dart';

enum TimetableDisplayMode {
  day,
  week,
}

class TimetableViewModel extends BaseViewModel {
  TimetableViewModel({
    TimetableModel? model,
  })  : _model = model ?? TimetableModel();

  final TimetableModel _model;

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
  List<int> get availableWeeks => _weekNumbers(_index);

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

  List<TimetableEntry> entriesForDay(int day) {
    final TimetableIndex? index = _index;
    if (index == null) {
      return const [];
    }
    List<TimetableEntry> entries;
    if (_selectedWeek != null) {
      final Map<int, List<TimetableEntry>>? weekMap =
          index.byWeekThenDay[_selectedWeek!];
      entries = weekMap?[day] ?? const [];
    } else {
      entries = index.byDayOfWeek[day] ?? const [];
    }
    final List<TimetableEntry> sorted = List<TimetableEntry>.from(entries);
    sorted.sort((a, b) {
      final int startA = a.timeStart ?? 0;
      final int startB = b.timeStart ?? 0;
      if (startA != startB) {
        return startA.compareTo(startB);
      }
      final int endA = a.timeEnd ?? 0;
      final int endB = b.timeEnd ?? 0;
      return endA.compareTo(endB);
    });
    return sorted;
  }

  Future<void> _loadCurrentWeek() async {
    _currentWeek = await _model.getSchoolCalendarCurrentWeek();
  }

  Future<void> _loadTimetable() async {
    try {
      _index = await _model.getTimetableIndex();
      _syncSelectedWeek();
    } catch (error) {
      _error = error;
    }
  }

  void _syncSelectedWeek() {
    final List<int> weeks = _weekNumbers(_index);
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

  List<int> _weekNumbers(TimetableIndex? index) {
    if (index == null) {
      return const [];
    }
    final List<int> weeks = index.byWeekThenDay.keys.toList();
    weeks.sort();
    return weeks;
  }
}
