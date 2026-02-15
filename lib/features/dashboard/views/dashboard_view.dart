import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onetj/models/event_model.dart';
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
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _eventSub = _viewModel.events.listen((event) {
      if (event is ShowSnackBarEvent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
        return;
      }
    });
    _viewModel.load();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(context),
          const SizedBox(height: 24),
          Text(
            l10n.dashboardUpcomingTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_viewModel.timetableLoading)
            const LinearProgressIndicator()
          else
            _buildUpcomingSection(
              context,
              entries: _viewModel.upcomingEntries,
            ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
  ) {
    final SchoolCalendarData? calendar = _viewModel.calendar;
    final l10n = AppLocalizations.of(context);

    final String department = _viewModel.departmentName ?? '';
    final bool isLoading =
        _viewModel.studentLoading || _viewModel.calendarLoading;
    final String termTitle = (calendar?.simpleName ?? '').isNotEmpty
        ? calendar!.simpleName
        : 'Term unavailable';
    final int weekNumber = calendar?.week != null ? calendar!.week : 0;
    final String departmentLabel =
        department.isNotEmpty ? department : 'Department unavailable';

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              termTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              departmentLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoPill(text: l10n.currentTeachingWeekText(weekNumber)),
              ],
            ),
            if (isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context, {
    required List<TimetableEntry> entries,
  }) {
    final l10n = AppLocalizations.of(context);
    if (entries.isEmpty) {
      return _EmptyState(
        icon: Icons.event_available,
        title: l10n.dashboardUpcomingEmpty,
      );
    }
    return Column(
      children: entries
          .map(
            (entry) => _UpcomingCard(
              title: entry.courseName.isNotEmpty
                  ? entry.courseName
                  : 'Unknown course',
              timeLabel:
                  '${_weekdayLabel(l10n, entry.dayOfWeek)} · ${_formatTimeRange(entry, _viewModel.timeSlotStartMinutes)}',
              roomLabel: entry.roomIdI18n.isNotEmpty
                  ? entry.roomIdI18n
                  : entry.roomLabel,
              teacherLabel:
                  entry.teacherName.isNotEmpty ? entry.teacherName : '-',
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

  String _formatTimeRange(TimetableEntry entry, List<int> startMinutes) {
    final String start = _slotLabel(entry.timeStart, startMinutes);
    final String end = _slotLabel(entry.timeEnd, startMinutes);
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

String _slotLabel(int slot, List<int> startMinutes) {
  final int index = slot - 1;
  if (index < 0 || index >= startMinutes.length) {
    return '';
  }
  return TimeSlot.formatMinutes(startMinutes[index]);
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.title,
    required this.timeLabel,
    required this.roomLabel,
    required this.teacherLabel,
  });

  final String title;
  final String timeLabel;
  final String roomLabel;
  final String teacherLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeBadge(label: timeLabel),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _MetaRow(
                  icon: Icons.room_outlined,
                  label: roomLabel,
                ),
                const SizedBox(height: 4),
                _MetaRow(
                  icon: Icons.person_outline,
                  label: teacherLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBadge extends StatelessWidget {
  const _TimeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
