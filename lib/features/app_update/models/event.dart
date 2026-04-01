import 'package:onetj/models/event_model.dart';

class AppUpdateMigrationLinkCopiedEvent extends UiEvent {
  const AppUpdateMigrationLinkCopiedEvent();
}

class AppUpdateMigrationLinkCopyFailedEvent extends UiEvent {
  const AppUpdateMigrationLinkCopyFailedEvent({
    required this.error,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
}

class AppUpdateMigrationDownloadOpenFailedEvent extends UiEvent {
  const AppUpdateMigrationDownloadOpenFailedEvent({
    required this.url,
  });

  final String url;
}
