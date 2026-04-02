import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/features/physics_lab/models/physics_lab_experiment.dart';

class PhysicsLabView extends StatelessWidget {
  const PhysicsLabView({super.key});

  static const List<PhysicsLabExperiment> _experiments =
      <PhysicsLabExperiment>[
    PhysicsLabExperiment.michelsonInterferometer,
    PhysicsLabExperiment.diffractionGrating,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.physicsLabTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.physicsLabSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          for (final PhysicsLabExperiment experiment in _experiments)
            _ExperimentTile(experiment: experiment),
        ],
      ),
    );
  }
}

class _ExperimentTile extends StatelessWidget {
  const _ExperimentTile({
    required this.experiment,
  });

  final PhysicsLabExperiment experiment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(experiment.icon, color: colors.primary),
        title: Text(_title(l10n)),
        subtitle: Text(_subtitle(l10n)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(experiment.route),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    switch (experiment) {
      case PhysicsLabExperiment.michelsonInterferometer:
        return l10n.physicsLabMichelsonTitle;
      case PhysicsLabExperiment.diffractionGrating:
        return l10n.physicsLabDiffractionGratingTitle;
    }
  }

  String _subtitle(AppLocalizations l10n) {
    switch (experiment) {
      case PhysicsLabExperiment.michelsonInterferometer:
        return l10n.physicsLabMichelsonSubtitle;
      case PhysicsLabExperiment.diffractionGrating:
        return l10n.physicsLabDiffractionGratingSubtitle;
    }
  }
}
