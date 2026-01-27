import 'package:flutter/material.dart';
import 'dart:async';

import 'package:onetj/features/home/view_models/home_view_model.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/repo/school_calendar_repository.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final HomeViewModel _viewModel;
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
    _viewModel = HomeViewModel();
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
          const Text('Timetable'),
          const SizedBox(height: 8),
          if (_timetableLoading)
            const LinearProgressIndicator()
          else if (_timetableError != null)
            Text('Failed to load timetable: $_timetableError')
          else if (_timetableEntries == null || _timetableEntries!.isEmpty)
            const Text('No timetable data')
          else
            Column(
              children: _timetableEntries!
                  .map(
                    (entry) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.courseName ?? 'Unknown course',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Day ${entry.dayOfWeek ?? '-'} | '
                            '${entry.timeStart ?? '-'}-${entry.timeEnd ?? '-'}',
                          ),
                          Text(
                            'Room: ${entry.roomIdI18n ?? entry.roomId ?? '-'}',
                          ),
                          Text(
                            'Teacher: ${entry.teacherName ?? '-'}',
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
    return body;
  }
}
