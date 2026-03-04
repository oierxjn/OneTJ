import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/app/logging/log_entry.dart';
import 'package:onetj/app/logging/log_formatter.dart';
import 'package:onetj/app/logging/logger.dart';

class LogViewerView extends StatelessWidget {
  const LogViewerView({super.key});

  static const int _maxEntries = 500;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<AppLogEntry> logs = AppLogger.recent(limit: _maxEntries);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsLogsTitle),
      ),
      body: logs.isEmpty
          ? Center(
              child: Text(l10n.settingsLogsEmpty),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final AppLogEntry entry = logs[index];
                return SelectableText(
                  entry.toPlainText(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.35,
                  ),
                );
              },
            ),
    );
  }
}
