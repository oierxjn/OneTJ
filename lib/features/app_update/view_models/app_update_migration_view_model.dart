import 'package:flutter/services.dart';

import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/features/app_update/models/event.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/services/external_launcher_service.dart';

class AppUpdateMigrationViewModel extends BaseViewModel<UiEvent> {
  AppUpdateMigrationViewModel({
    ExternalLauncherService? externalLauncherService,
  }) : _externalLauncherService =
            externalLauncherService ?? ExternalLauncherService.getInstance();

  final ExternalLauncherService _externalLauncherService;

  bool _opening = false;
  bool _copying = false;

  bool get opening => _opening;
  bool get copying => _copying;

  Future<void> downloadNow(String url) async {
    if (_opening) {
      return;
    }
    _opening = true;
    notifyListeners();
    try {
      final ExternalUrlLaunchResult result =
          await _externalLauncherService.openExternalUrl(url);
      if (result == ExternalUrlLaunchResult.failed) {
        AppLogger.warning(
          'Failed to open migration download URL',
          loggerName: 'AppUpdateMigrationViewModel',
          context: <String, Object?>{
            'url': url,
          },
        );
        emit(AppUpdateMigrationDownloadOpenFailedEvent(url: url));
      }
    } finally {
      _opening = false;
      notifyListeners();
    }
  }

  Future<void> copyLink(String url) async {
    if (_copying) {
      return;
    }
    _copying = true;
    notifyListeners();
    try {
      await Clipboard.setData(ClipboardData(text: url));
      emit(const AppUpdateMigrationLinkCopiedEvent());
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to copy migration download URL',
        loggerName: 'AppUpdateMigrationViewModel',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'url': url,
        },
      );
      emit(
        AppUpdateMigrationLinkCopyFailedEvent(
          error: error,
          stackTrace: stackTrace,
        ),
      );
    } finally {
      _copying = false;
      notifyListeners();
    }
  }
}
