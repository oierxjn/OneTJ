import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/grades/view_models/grades_view_model.dart';
import 'package:onetj/models/event_model.dart';

class GradesView extends StatefulWidget {
  const GradesView({super.key});

  @override
  State<GradesView> createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  late final GradesViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = GradesViewModel();
    _eventSub = _viewModel.events.listen((event) {
      if (event is ShowSnackBarEvent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
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
        title: Text(l10n.scoreInquiryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _viewModel.loading ? null : _viewModel.refresh,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => _buildBody(context, l10n),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final data = _viewModel.viewData;
    final selectedTerm = _viewModel.selectedTerm;

    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_viewModel.loading) const LinearProgressIndicator(),
          if (_viewModel.loading) const SizedBox(height: 16),
          if (data != null)
            _SummaryCard(
              title: l10n.scoresOverviewTitle,
              items: [
                _SummaryItem(
                  label: l10n.scoresSummaryGpa,
                  value: data.summary.totalGradePoint,
                ),
                _SummaryItem(
                  label: l10n.scoresSummaryCredits,
                  value: data.summary.actualCredit,
                ),
                _SummaryItem(
                  label: l10n.scoresSummaryFailed,
                  value: data.summary.failingCourseCount,
                ),
              ],
            ),
          if (data != null) const SizedBox(height: 16),
          if (data != null && data.terms.isNotEmpty)
            _TermSelector(
              terms: data.terms.map((term) => term.termName).toList(),
              selectedIndex: _viewModel.selectedTermIndex,
              onChanged: _viewModel.selectTerm,
            ),
          if (data != null && data.terms.isNotEmpty) const SizedBox(height: 16),
          Text(
            l10n.scoresListTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (data == null || selectedTerm == null || selectedTerm.courses.isEmpty)
            _EmptyState(message: l10n.scoresEmpty),
          if (selectedTerm != null)
            ...selectedTerm.courses.map(
              (course) => _GradeRow(
                courseName: course.courseName,
                score: course.score,
                credit: course.credit,
                gradePoint: course.gradePoint,
                courseType: course.courseType,
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.items,
  });

  final String title;
  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: items
                  .map(
                    (item) => _SummaryPill(
                      label: item.label,
                      value: item.value,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
          ),
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.courseName,
    required this.score,
    required this.credit,
    required this.gradePoint,
    required this.courseType,
  });

  final String courseName;
  final String score;
  final String credit;
  final String gradePoint;
  final String courseType;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              courseName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
              'GPA $gradePoint · $credit · $courseType',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TermSelector extends StatelessWidget {
  const _TermSelector({
    required this.terms,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> terms;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) {
      return const SizedBox.shrink();
    }
    return DropdownButtonFormField<int>(
      value: selectedIndex.clamp(0, terms.length - 1),
      items: [
        for (int i = 0; i < terms.length; i += 1)
          DropdownMenuItem(
            value: i,
            child: Text(terms[i]),
          ),
      ],
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
      ),
    );
  }
}
