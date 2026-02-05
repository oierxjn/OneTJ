import 'package:onetj/models/event_model.dart';

class SettingsSavedEvent extends UiEvent {
  const SettingsSavedEvent({required this.maxWeek});

  final int maxWeek;
}
