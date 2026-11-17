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

class AppUpdateInstallPermissionRequiredEvent extends UiEvent {
  const AppUpdateInstallPermissionRequiredEvent();
}

class AppUpdateFailedEvent extends UiEvent {
  const AppUpdateFailedEvent({
    required this.error,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;
}

/// 仪表盘本轮平台数据加载出现瞬时失败。
///
/// 语义结果事件：只描述「本轮加载有失败」，不携带错误原文、文案或目的地。
/// 凭证失败不发此事件（失效态已有登录引导卡片）；视图将其映射为一条
/// 本地化提示，同一轮多个数据源失败只提示一次（#82）。
class DashboardLoadFailedEvent extends UiEvent {
  const DashboardLoadFailedEvent();
}
