import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:onetj/app/constant/route_paths.dart';

class DeveloperSettingsView extends StatelessWidget {
  const DeveloperSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsDeveloperPageTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(l10n.settingsLogsTitle),
              subtitle: Text(l10n.settingsLogsSubtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RoutePaths.homeSettingsDeveloperLogs),
            ),
          ),
        ],
      ),
    );
  }
}
