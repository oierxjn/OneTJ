sealed class BaseEvent {
  const BaseEvent();
}
sealed class UiEvent extends BaseEvent {
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
