import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:onetj/features/home/views/widgets/home_shell_back_button.dart';

import 'package:onetj/app/constant/route_paths.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Widget? homeBackButton = buildHomeShellBackButton(context);
    return Scaffold(
      appBar: AppBar(
        leading: homeBackButton,
        leadingWidth:
            homeBackButton == null ? null : homeShellBackButtonLeadingWidth,
        title: Text(l10n.tabTools),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Text(
            l10n.toolsSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          _ToolTile(
            icon: Icons.science_outlined,
            title: l10n.physicsLabTitle,
            subtitle: l10n.physicsLabToolSubtitle,
            onTap: () => context.push(RoutePaths.homePhysicsLab),
          ),
          _ToolTile(
            icon: Icons.auto_graph_outlined,
            title: l10n.scoreInquiryTitle,
            subtitle: l10n.scoreInquirySubtitle,
            onTap: () => context.push(RoutePaths.homeGrades),
          ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
