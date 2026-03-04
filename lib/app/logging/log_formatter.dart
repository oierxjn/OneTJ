import 'package:onetj/app/logging/log_entry.dart';

class AppLogFormatter {
  const AppLogFormatter._();

  static String toPlainText(AppLogEntry entry) {
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

  static List<String> toPlainTextLines(List<AppLogEntry> entries) {
    return entries.map(toPlainText).toList(growable: false);
  }
}

extension AppLogEntryPlainText on AppLogEntry {
  String toPlainText() => AppLogFormatter.toPlainText(this);
}
