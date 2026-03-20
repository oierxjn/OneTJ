import 'package:onetj/models/app_update_info.dart';

class BaseEvent {
  const BaseEvent();
}

class UiEvent extends BaseEvent {
  final String? message;
  final String? code;
  const UiEvent({this.message, this.code});
}

class ShowToastEvent extends UiEvent {
  const ShowToastEvent({super.message, super.code});
}

class ShowSnackBarEvent extends UiEvent {
  const ShowSnackBarEvent({super.message, super.code});
}

class NavigateEvent extends UiEvent {
  final String route;
  const NavigateEvent(this.route);
}

class AppUpdateAvailableEvent extends UiEvent {
  const AppUpdateAvailableEvent({
    required this.updateInfo,
    this.fromManualCheck = false,
  });

  final AppUpdateInfo updateInfo;
  final bool fromManualCheck;
}

class AppUpdateAlreadyLatestEvent extends UiEvent {
  const AppUpdateAlreadyLatestEvent();
}

class AppUpdateInstallTriggeredEvent extends UiEvent {
  const AppUpdateInstallTriggeredEvent();
}

class AppUpdateFailedEvent extends UiEvent {
  const AppUpdateFailedEvent({
    required this.error,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
}
