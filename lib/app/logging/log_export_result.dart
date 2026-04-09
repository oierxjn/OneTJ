enum AppLogExportMethod {
  saveFile,
  directoryPicker,
  appFallback,
}

class AppLogExportResult {
  const AppLogExportResult({
    required this.path,
    required this.method,
  });

  final String path;
  final AppLogExportMethod method;
}
