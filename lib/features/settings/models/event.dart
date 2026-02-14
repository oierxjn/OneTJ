import 'package:onetj/models/event_model.dart';
import 'package:onetj/repo/settings_repository.dart';

class SettingsSavedEvent extends UiEvent {
  const SettingsSavedEvent({required this.settings});

  final SettingsData settings;
}

class SettingsResetEvent extends UiEvent {
  const SettingsResetEvent({required this.settings});

  final SettingsData settings;
}
