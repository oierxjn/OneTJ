import 'package:onetj/models/timetable_index.dart';

class DashboardUpcomingEntryData {
  const DashboardUpcomingEntryData({
    required this.entry,
    required this.isOngoing,
  });

  final TimetableEntry entry;
  final bool isOngoing;
}
