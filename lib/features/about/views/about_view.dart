import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/about/models/acknowledgement_model.dart';
import 'package:onetj/features/about/models/contributor_model.dart';
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

  Widget _buildContributorTile(ContributorProfile contributor) {
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage(contributor.avatarAssetPath),
      ),
      title: Text(
        contributor.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle:
          contributor.userName == null ? null : Text(contributor.userName!),
    );
  }

  Widget _buildContributorsCard(AppLocalizations l10n) {
    final List<ContributorProfile> contributors =
        ContributorsModel.contributors;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: Text(l10n.aboutContributorsTitle),
          ),
          const Divider(height: 1),
          ...contributors.map(_buildContributorTile),
        ],
      ),
    );
  }

  String? _resolveAcknowledgementDescription(
    AppLocalizations l10n,
    AcknowledgementDescriptionKey? key,
  ) {
    if (key == null) {
      return null;
    }
    switch (key) {
      case AcknowledgementDescriptionKey.flutter:
        return l10n.aboutAckFlutterDescription;
      case AcknowledgementDescriptionKey.tjpb:
        return l10n.aboutAckTjpbDescription;
    }
  }

  Widget _buildAcknowledgementTile(
    AppLocalizations l10n,
    OrganizationAcknowledgement organization,
  ) {
    final String? description = _resolveAcknowledgementDescription(
      l10n,
      organization.descriptionKey,
    );
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          organization.logoAssetPath,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        organization.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: description == null ? null : Text(description),
    );
  }

  Widget _buildAcknowledgementsCard(AppLocalizations l10n) {
    final List<OrganizationAcknowledgement> organizations =
        AcknowledgementsModel.organizations;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: Text(l10n.aboutAcknowledgementsTitle),
          ),
          const Divider(height: 1),
          ...organizations.map(
            (OrganizationAcknowledgement organization) =>
                _buildAcknowledgementTile(l10n, organization),
          ),
        ],
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icon/logo.jpg',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
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
          const SizedBox(height: 12),
          _buildContributorsCard(l10n),
          const SizedBox(height: 12),
          _buildAcknowledgementsCard(l10n),
        ],
      ),
    );
  }
}
