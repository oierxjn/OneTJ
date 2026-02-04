import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/models/timetable_index.dart';
import 'package:onetj/models/time_slot.dart';
import 'package:onetj/repo/school_calendar_repository.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tabDashboard),
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => _buildBody(context, l10n),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final String studentText = _viewModel.studentInfo ?? '';
    final SchoolCalendarData? calendar = _viewModel.calendar;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Info'),
          const SizedBox(height: 8),
          if (_viewModel.studentLoading)
            const LinearProgressIndicator()
          else if (_viewModel.studentError != null)
            Text('Failed to load student info: ${_viewModel.studentError}')
          else
            SelectableText(studentText.isEmpty ? 'No data' : studentText),
          const SizedBox(height: 24),
          const Text('Calendar'),
          const SizedBox(height: 8),
          if (_viewModel.calendarLoading)
            const LinearProgressIndicator()
          else if (_viewModel.calendarError != null)
            Text('Failed to load calendar: ${_viewModel.calendarError}')
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
          if (_viewModel.timetableLoading)
            const LinearProgressIndicator()
          else if (_viewModel.timetableError != null)
            Text('Failed to load timetable: ${_viewModel.timetableError}')
          else
            _buildUpcomingSection(
              context,
              entries: _viewModel.upcomingEntries,
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context, {
    required List<TimetableEntry> entries,
  }) {
    final l10n = AppLocalizations.of(context);
    if (entries.isEmpty) {
      return Text(l10n.dashboardUpcomingEmpty);
    }
    return Column(
      children: entries
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

String _slotLabel(int slot) {
  final int index = slot - 1;
  final List<int> startMinutes = TimeSlot.defaultConfig.startMinutes;
  if (index < 0 || index >= startMinutes.length) {
    return '';
  }
  return TimeSlot.formatMinutes(startMinutes[index]);
}
