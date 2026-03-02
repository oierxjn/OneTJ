enum DashboardUpcomingMode {
  thisWeek('thisWeek'),
  today('today'),
  count('count');

  const DashboardUpcomingMode(this.jsonValue);

  final String jsonValue;

  static DashboardUpcomingMode fromJsonValue(Object? value) {
    if (value is! String) {
      return DashboardUpcomingMode.thisWeek;
    }
    for (final DashboardUpcomingMode mode in DashboardUpcomingMode.values) {
      if (mode.jsonValue == value) {
        return mode;
      }
    }
    return DashboardUpcomingMode.thisWeek;
  }
}
