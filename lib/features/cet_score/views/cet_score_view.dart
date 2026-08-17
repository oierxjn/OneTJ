import 'dart:async';

import 'package:flutter/material.dart';

import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/cet_score/models/cet_score_view_data.dart';
import 'package:onetj/features/cet_score/view_models/cet_score_view_model.dart';
import 'package:onetj/l10n/app_localizations.dart';

class CetScoreView extends StatefulWidget {
  const CetScoreView({required this.viewModel, super.key});

  final CetScoreViewModel viewModel;

  @override
  State<CetScoreView> createState() => _CetScoreViewState();
}

class _CetScoreViewState extends State<CetScoreView> {
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub = widget.viewModel.events.listen((UiEvent event) {
      if (event is ShowSnackBarEvent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(event.message ?? '')),
        );
      }
    });
    widget.viewModel.load();
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
        title: Text(l10n.cetScoreTitle),
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
          final List<CetScoreViewRecord> records = widget.viewModel.records;
          if (widget.viewModel.loading && records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: widget.viewModel.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                if (records.isEmpty)
                  _EmptyState(message: l10n.cetScoreEmpty)
                else
                  for (final CetScoreViewRecord record in records)
                    _CetScoreCard(record: record),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CetScoreCard extends StatelessWidget {
  const _CetScoreCard({required this.record});

  final CetScoreViewRecord record;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        record.levelLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        record.termName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  record.score,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
                label: l10n.cetScoreTicketNumberLabel,
                value: record.ticketNumber),
            _InfoRow(label: l10n.cetScoreStudentLabel, value: record.student),
            _InfoRow(
                label: l10n.cetScoreSubjectLabel, value: record.subjectName),
            _InfoRow(
                label: l10n.cetScoreOralScoreLabel, value: record.oralScore),
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
            width: 72,
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
