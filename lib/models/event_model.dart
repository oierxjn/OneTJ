sealed class BaseEvent {
  const BaseEvent();
}
sealed class UiEvent extends BaseEvent {
  const UiEvent();
}
class ShowToastEvent extends UiEvent {
  final String message;
  const ShowToastEvent(this.message);
}
class ShowSnackBarEvent extends UiEvent {
  final String message;
  const ShowSnackBarEvent(this.message);
}
