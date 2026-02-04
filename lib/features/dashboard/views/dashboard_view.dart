import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/school_calendar_repository.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;
  StreamSubscription<String>? _infoSub;
  StreamSubscription<SchoolCalendarData>? _calendarSub;
  StreamSubscription<List<TimetableEntry>>? _timetableSub;
  StreamSubscription<Object>? _studentErrorSub;
  StreamSubscription<Object>? _calendarErrorSub;
  StreamSubscription<Object>? _timetableErrorSub;
  String? _studentInfo;
  SchoolCalendarData? _calendar;
  List<TimetableEntry>? _timetableEntries;
  Object? _studentError;
  Object? _calendarError;
  Object? _timetableError;
  bool _studentLoading = true;
  bool _calendarLoading = true;
  bool _timetableLoading = true;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _infoSub = _viewModel.studentInfo.listen((data) {
      if (!mounted) return;
      setState(() {
        _studentInfo = data;
        _studentError = null;
        _studentLoading = false;
      });
    });
    _calendarSub = _viewModel.schoolCalendar.listen((data) {
      if (!mounted) return;
      setState(() {
        _calendar = data;
        _calendarError = null;
        _calendarLoading = false;
      });
    });
    _timetableSub = _viewModel.timetableEntries.listen((data) {
      if (!mounted) return;
      setState(() {
        _timetableEntries = data;
        _timetableError = null;
        _timetableLoading = false;
      });
    });
    _studentErrorSub = _viewModel.studentErrors.listen((error) {
      if (!mounted) return;
      setState(() {
        _studentError = error;
        _studentLoading = false;
      });
    });
    _calendarErrorSub = _viewModel.calendarErrors.listen((error) {
      if (!mounted) return;
      setState(() {
        _calendarError = error;
        _calendarLoading = false;
      });
    });
    _timetableErrorSub = _viewModel.timetableErrors.listen((error) {
      if (!mounted) return;
      setState(() {
        _timetableError = error;
        _timetableLoading = false;
      });
    });
    _viewModel.loadStudentInfo();
    _viewModel.loadSchoolCalendar();
    _viewModel.loadCourseSchedule();
  }

  @override
  void dispose() {
    _infoSub?.cancel();
    _calendarSub?.cancel();
    _timetableSub?.cancel();
    _studentErrorSub?.cancel();
    _calendarErrorSub?.cancel();
    _timetableErrorSub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String studentText = _studentInfo ?? '';
    final SchoolCalendarData? calendar = _calendar;
    final l10n = AppLocalizations.of(context);
    final Widget body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Info'),
          const SizedBox(height: 8),
          if (_studentLoading)
            const LinearProgressIndicator()
          else if (_studentError != null)
            Text('Failed to load student info: $_studentError')
          else
            SelectableText(studentText.isEmpty ? 'No data' : studentText),
          const SizedBox(height: 24),
          const Text('Calendar'),
          const SizedBox(height: 8),
          if (_calendarLoading)
            const LinearProgressIndicator()
          else if (_calendarError != null)
            Text('Failed to load calendar: $_calendarError')
          else if (calendar == null)
            const Text('No calendar data')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current week: ${calendar.week}'),
                const SizedBox(height: 4),
                Text('Term: ${calendar.simpleName}'),
              ],
            ),
          const SizedBox(height: 24),
          Text(l10n.dashboardUpcomingTitle),
          const SizedBox(height: 8),
          if (_timetableLoading)
            const LinearProgressIndicator()
          else if (_timetableError != null)
            Text('Failed to load timetable: $_timetableError')
          else
            _buildUpcomingSection(
              context,
              entries: _timetableEntries ?? const [],
              currentWeek: calendar?.week,
            ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tabDashboard),
      ),
      body: body,
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context, {
    required List<TimetableEntry> entries,
    required int? currentWeek,
  }) {
    final l10n = AppLocalizations.of(context);
    final List<TimetableEntry> upcoming = _upcomingEntries(
      entries: entries,
      currentWeek: currentWeek,
      now: DateTime.now(),
      limit: 3,
    );
    if (upcoming.isEmpty) {
      return Text(l10n.dashboardUpcomingEmpty);
    }
    return Column(
      children: upcoming
          .map(
            (entry) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.courseName.isNotEmpty ? entry.courseName : 'Unknown course',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_weekdayLabel(l10n, entry.dayOfWeek)} | ${_formatTimeRange(entry)}',
                  ),
                  Text(
                    'Room: ${entry.roomIdI18n.isNotEmpty ? entry.roomIdI18n : (entry.roomId.isNotEmpty ? entry.roomId : '-')}',
                  ),
                  Text(
                    'Teacher: ${entry.teacherName.isNotEmpty ? entry.teacherName : '-'}',
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  List<TimetableEntry> _upcomingEntries({
    required List<TimetableEntry> entries,
    required int? currentWeek,
    required DateTime now,
    int limit = 3,
  }) {
    if (entries.isEmpty || currentWeek == null || limit <= 0) {
      return const [];
    }
    final int today = now.weekday;
    final List<TimetableEntry> result = [];
    for (int day = today; day <= 7 && result.length < limit; day += 1) {
      final List<TimetableEntry> dayEntries = entries
          .where((entry) => entry.dayOfWeek == day && _matchesWeek(entry, currentWeek))
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
    if (index < 0 || index >= _slotStartMinutes.length) {
      return true;
    }
    final int startMinutes = _slotStartMinutes[index];
    final int nowMinutes = now.hour * 60 + now.minute;
    return startMinutes > nowMinutes;
  }

  String _weekdayLabel(AppLocalizations l10n, int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return l10n.weekdayMon;
      case 2:
        return l10n.weekdayTue;
      case 3:
        return l10n.weekdayWed;
      case 4:
        return l10n.weekdayThu;
      case 5:
        return l10n.weekdayFri;
      case 6:
        return l10n.weekdaySat;
      case 7:
        return l10n.weekdaySun;
      default:
        return l10n.weekdayMon;
    }
  }

  String _formatTimeRange(TimetableEntry entry) {
    final String start = _slotLabel(entry.timeStart);
    final String end = _slotLabel(entry.timeEnd);
    if (start.isEmpty && end.isEmpty) {
      return '${entry.timeStart}-${entry.timeEnd}';
    }
    if (start.isEmpty) {
      return '${entry.timeStart}-$end';
    }
    if (end.isEmpty) {
      return '$start-${entry.timeEnd}';
    }
    return '$start-$end';
  }
}

const List<int> _slotStartMinutes = [
  8 * 60,
  8 * 60 + 55,
  10 * 60,
  10 * 60 + 55,
  13 * 60 + 30,
  14 * 60 + 25,
  15 * 60 + 30,
  16 * 60 + 25,
  18 * 60 + 30,
  19 * 60 + 25,
];

const List<String> _slotStartLabels = [
  '08:00',
  '08:55',
  '10:00',
  '10:55',
  '13:30',
  '14:25',
  '15:30',
  '16:25',
  '18:30',
  '19:25',
];

String _slotLabel(int slot) {
  final int index = slot - 1;
  if (index < 0 || index >= _slotStartLabels.length) {
    return '';
  }
  return _slotStartLabels[index];
}
