import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/about/view_models/about_view_model.dart';

const String _kProjectRepoUrl = 'https://github.com/oierxjn/OneTJ';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  final AboutViewModel _viewModel = AboutViewModel();

  Future<void> _copyRepoUrl(AppLocalizations l10n) async {
    await Clipboard.setData(const ClipboardData(text: _kProjectRepoUrl));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.aboutCopied)),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsAboutTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aboutDescription,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.apps_outlined,
            title: l10n.aboutAppNameLabel,
            value: _viewModel.appName,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.new_releases_outlined,
            title: l10n.aboutVersionLabel,
            value: _viewModel.version,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.tag_outlined,
            title: l10n.aboutBuildLabel,
            value: _viewModel.buildNumber,
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.link_outlined),
              title: Text(l10n.aboutRepoLabel),
              subtitle: const Text(_kProjectRepoUrl),
              trailing: const Icon(Icons.copy_outlined),
              onTap: () => _copyRepoUrl(l10n),
            ),
          ),
        ],
      ),
    );
  }
}
