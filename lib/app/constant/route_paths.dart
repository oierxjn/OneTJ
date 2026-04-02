class RoutePaths {
  const RoutePaths._();

  static const String launcher = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String homeDashboard = '$home/dashboard';
  static const String homeTimetable = '$home/timetable';
  static const String homeSettings = '$home/settings';
  static const String homeSettingsTimeSlots = '$homeSettings/time-slots';
  static const String homeSettingsLaunchWallpaper =
      '$homeSettings/launch-wallpaper';
  static const String homeSettingsUserCollectionPolicy =
      '$homeSettings/user-collection-policy';
  static const String homeSettingsAbout = '$homeSettings/about';
  static const String homeSettingsDeveloper = '$homeSettings/developer';
  static const String homeSettingsDeveloperLogs = '$homeSettingsDeveloper/logs';
  static const String homeTools = '$home/tools';
  static const String homePhysicsLab = '$homeTools/physics-lab';
  static const String homePhysicsLabMichelson = '$homePhysicsLab/michelson';
  static const String homePhysicsLabDiffractionGrating =
      '$homePhysicsLab/diffraction-grating';
  static const String homeGrades = '$home/grades';
}
