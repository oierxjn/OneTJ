import 'package:flutter/material.dart';
import 'dart:async';

import 'package:onetj/features/home/view_models/home_view_model.dart';
import 'package:onetj/repo/school_calendar_repository.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;
  StreamSubscription<String>? _infoSub;
  StreamSubscription<SchoolCalendarData>? _calendarSub;
  StreamSubscription<Object>? _studentErrorSub;
  StreamSubscription<Object>? _calendarErrorSub;
  String? _studentInfo;
  SchoolCalendarData? _calendar;
  Object? _studentError;
  Object? _calendarError;
  bool _studentLoading = true;
  bool _calendarLoading = true;
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
    _viewModel.loadStudentInfo();
    _viewModel.loadSchoolCalendar();
  }
  @override
  void dispose() {
    _infoSub?.cancel();
    _calendarSub?.cancel();
    _studentErrorSub?.cancel();
    _calendarErrorSub?.cancel();
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
        ],
      ),
    );
    return Scaffold(
      body: body,
    );
  }
}
