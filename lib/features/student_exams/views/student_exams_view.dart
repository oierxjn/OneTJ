import 'dart:async';

import 'package:flutter/material.dart';

import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/student_exams/models/student_exam_view_data.dart';
import 'package:onetj/features/student_exams/view_models/student_exam_view_model.dart';
import 'package:onetj/l10n/app_localizations.dart';

class StudentExamsView extends StatefulWidget {
  const StudentExamsView({required this.viewModel, super.key});

  final StudentExamViewModel viewModel;

  @override
  State<StudentExamsView> createState() => _StudentExamsViewState();
}

class _StudentExamsViewState extends State<StudentExamsView> {
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub = widget.viewModel.events.listen((UiEvent event) {
      if (!mounted) return;
      if (event is StudentExamFetchFailedEvent) {
        _showFetchFailedSnackBar(event);
        return;
      }
      if (event is ShowSnackBarEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
      }
    });
    widget.viewModel.load();
  }

  void _showFetchFailedSnackBar(StudentExamFetchFailedEvent event) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.errorContainer,
        duration: const Duration(seconds: 8),
        content: Row(
          children: <Widget>[
            Icon(Icons.warning_amber_rounded, color: colors.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.showingCachedData
                    ? l10n.studentExamsLatestFetchFailedUsingCache
                    : l10n.studentExamsLatestFetchFailed,
                style: TextStyle(color: colors.onErrorContainer),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: l10n.retryLabel,
          textColor: colors.onErrorContainer,
          onPressed: widget.viewModel.refresh,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.studentExamsTitle),
        actions: <Widget>[
          AnimatedBuilder(
            animation: widget.viewModel,
            builder: (BuildContext context, Widget? child) {
              return IconButton(
                tooltip: MaterialLocalizations.of(context)
                    .refreshIndicatorSemanticLabel,
                onPressed: widget.viewModel.loading
                    ? null
                    : () => widget.viewModel.refresh(),
                icon: const Icon(Icons.refresh),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (BuildContext context, Widget? child) {
          final List<StudentExamViewRecord> records = widget.viewModel.records;
          if (widget.viewModel.loading && records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: widget.viewModel.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (widget.viewModel.termName.isNotEmpty)
                  _TermHeader(
                    label: l10n.studentExamsTermLabel,
                    termName: widget.viewModel.termName,
                  ),
                if (records.isEmpty)
                  _EmptyState(message: l10n.studentExamsEmpty)
                else
                  for (final StudentExamViewRecord record in records)
                    _StudentExamCard(record: record),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TermHeader extends StatelessWidget {
  const _TermHeader({required this.label, required this.termName});

  final String label;
  final String termName;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        '$label：$termName',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _StudentExamCard extends StatelessWidget {
  const _StudentExamCard({required this.record});

  final StudentExamViewRecord record;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isExam = record.isExam;
    final Color background =
        isExam ? colors.primaryContainer : colors.surfaceContainerHighest;
    final Color foreground =
        isExam ? colors.onPrimaryContainer : colors.onSurfaceVariant;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  isExam
                      ? Icons.assignment_turned_in_outlined
                      : Icons.event_note_outlined,
                  color: foreground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        record.courseName.isEmpty ? '—' : record.courseName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isExam
                            ? l10n.studentExamsFormalLabel
                            : l10n.studentExamsArrangementLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: foreground,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
              label: l10n.studentExamsCourseCodeLabel,
              value: record.courseCode,
            ),
            if (record.examTime != null)
              _InfoRow(
                label: l10n.studentExamsTimeLabel,
                value: record.examTime!,
              ),
            if (record.roomName != null)
              _InfoRow(
                label: l10n.studentExamsRoomLabel,
                value: record.roomName!,
              ),
            if (record.remark != null)
              _InfoRow(
                label: l10n.studentExamsRemarkLabel,
                value: record.remark!,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Text(message),
      ),
    );
  }
}
