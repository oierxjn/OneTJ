import 'package:onetj/models/event_model.dart';
import 'package:onetj/repo/settings_repository.dart';
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

class DeveloperDebugUploadFailedEvent extends UiEvent {
  const DeveloperDebugUploadFailedEvent({super.message});
}
