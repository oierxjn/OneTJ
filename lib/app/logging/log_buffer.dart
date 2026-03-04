import 'dart:collection';

import 'package:onetj/app/logging/log_entry.dart';

class AppLogBuffer {
  AppLogBuffer({required int capacity})
      : assert(capacity > 0),
        _capacity = capacity;

  final int _capacity;
  final Queue<AppLogEntry> _queue = Queue<AppLogEntry>();

  void add(AppLogEntry entry) {
    if (_queue.length >= _capacity) {
      _queue.removeFirst();
    }
    _queue.addLast(entry);
  }

  List<AppLogEntry> recent({int limit = 100}) {
    if (_queue.isEmpty) {
      return const <AppLogEntry>[];
    }
    final int safeLimit = limit <= 0 ? 0 : limit;
    if (safeLimit == 0) {
      return const <AppLogEntry>[];
    }
    final List<AppLogEntry> all = _queue.toList(growable: false);
    if (safeLimit >= all.length) {
      return all;
    }
    return all.sublist(all.length - safeLimit);
  }
}
