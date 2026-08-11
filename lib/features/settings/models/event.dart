import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/services/hive_storage_service.dart';

class SettingsSavedEvent extends UiEvent {
  const SettingsSavedEvent({required this.settings});

  final SettingsData settings;
}

class SettingsResetEvent extends UiEvent {
  const SettingsResetEvent({required this.settings});

  final SettingsData settings;
}

class SettingsDataMigrationEvent extends UiEvent {
  const SettingsDataMigrationEvent({required this.result});

  final HiveDataMigrationResult result;
}

class SettingsDataMigrationFailedEvent extends UiEvent {
  const SettingsDataMigrationFailedEvent();
}

class SettingsDataCleanupEvent extends UiEvent {
  const SettingsDataCleanupEvent({required this.result});

  final HiveDataCleanupResult result;
}

class SettingsDataCleanupFailedEvent extends UiEvent {
  const SettingsDataCleanupFailedEvent();
}

class DeveloperDebugUploadSuccessEvent extends UiEvent {
  const DeveloperDebugUploadSuccessEvent();
}

class DeveloperDebugEndpointInvalidEvent extends UiEvent {
  const DeveloperDebugEndpointInvalidEvent({
    required this.type,
  }) : super(code: type);
  final String type;
}

class DeveloperDebugUploadFailedEvent extends UiEvent {
  const DeveloperDebugUploadFailedEvent({super.message});
}

class LogExportSucceededEvent extends UiEvent {
  const LogExportSucceededEvent({required this.path});

  final String path;
}

class LogExportCanceledEvent extends UiEvent {
  const LogExportCanceledEvent();
}

class LogExportFailedEvent extends UiEvent {
  const LogExportFailedEvent({super.message});
}

class LogOpenSucceededEvent extends UiEvent {
  const LogOpenSucceededEvent({required this.path});

  final String path;
}

class LogOpenFailedEvent extends UiEvent {
  const LogOpenFailedEvent({super.message});
}
