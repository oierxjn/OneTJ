class AppLogFileInfo {
  const AppLogFileInfo({
    required this.name,
    required this.path,
    required this.date,
    required this.sizeBytes,
    required this.isCurrent,
  });

  final String name;
  final String path;
  final DateTime date;
  final int sizeBytes;
  final bool isCurrent;
}
