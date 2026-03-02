enum DashboardUpcomingMode {
  thisWeek('thisWeek'),
  today('today'),
  count('count');

  const DashboardUpcomingMode(this.jsonValue);

  final String jsonValue;

  static DashboardUpcomingMode fromJsonValue(
    Object? value, {
    DashboardUpcomingMode defaultValue = DashboardUpcomingMode.thisWeek,
  }) {
    if (value is! String) {
      return defaultValue;
    }
    for (final DashboardUpcomingMode mode in DashboardUpcomingMode.values) {
      if (mode.jsonValue == value) {
        return mode;
      }
    }
    return defaultValue;
  }
}
