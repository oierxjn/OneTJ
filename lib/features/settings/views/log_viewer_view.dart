import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/app/logging/app_log_entry.dart';
import 'package:onetj/app/logging/app_logger.dart';

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
                  _formatEntry(entry),
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

  String _formatEntry(AppLogEntry entry) {
    final StringBuffer buffer = StringBuffer()
      ..write(entry.time.toIso8601String())
      ..write(' [')
      ..write(entry.level.name)
      ..write('] ')
      ..write(entry.loggerName)
      ..write(': ')
      ..write(entry.message);
    if (entry.code != null) {
      buffer
        ..write(' (code=')
        ..write(entry.code)
        ..write(')');
    }
    if (entry.context.isNotEmpty) {
      buffer
        ..write(' context=')
        ..write(entry.context);
    }
    if (entry.error != null && entry.error!.isNotEmpty) {
      buffer
        ..write(' error=')
        ..write(entry.error);
    }
    return buffer.toString();
  }
}
