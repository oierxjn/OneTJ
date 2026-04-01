import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/features/app_update/models/event.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/services/app_update_service.dart';

class AppUpdatePromptViewModel extends BaseViewModel<UiEvent> {
  AppUpdatePromptViewModel({
    required AppUpdateService appUpdateService,
  }) : _appUpdateService = appUpdateService;

  final AppUpdateService _appUpdateService;

  bool _skipping = false;

  bool get skipping => _skipping;
  bool get busy => _skipping;

  Future<bool> skipVersion(String versionTag) async {
    if (_skipping) {
      return false;
    }
    _skipping = true;
    notifyListeners();
    try {
      await _appUpdateService.skipVersion(versionTag);
      return true;
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to skip app update version',
        loggerName: 'AppUpdatePromptViewModel',
        error: error,
        stackTrace: stackTrace,
        context: <String, Object?>{
          'versionTag': versionTag,
        },
      );
      emit(
        AppUpdateSkipVersionFailedEvent(
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return false;
    } finally {
      _skipping = false;
      notifyListeners();
    }
  }
}
