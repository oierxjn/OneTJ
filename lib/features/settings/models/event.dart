import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/models/settings_data.dart';
import 'package:onetj/services/hive_storage_service.dart';

/// 设置页会持久化的设置项，对应会给出保存反馈的卡片。
enum SettingsCardField {
  maxWeek,
  timeSlots,
  upcoming,
  userCollection,
  launchWallpaper,
}

/// 某个设置项持久化成功后的卡片反馈事件。
class SettingsSavedFeedbackEvent extends UiEvent {
  const SettingsSavedFeedbackEvent({required this.field});

  final SettingsCardField field;
}

class SettingsResetEvent extends UiEvent {
  const SettingsResetEvent({required this.settings});

  final SettingsData settings;
}

/// 登出已完成（会话已翻转为游客态），但部分尽力清理步骤失败。
///
/// 语义结果事件：不携带路由；视图据此展示降级警告并照常完成登出导航。
class LogoutCompletedWithWarningEvent extends UiEvent {
  const LogoutCompletedWithWarningEvent({required this.failedSteps});

  final List<String> failedSteps;
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
