import 'dart:async';

import 'package:onetj/app/constant/app_version_constant.dart';
import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/services/app_update_service.dart';

class AboutViewModel extends BaseViewModel {
  AboutViewModel({
    AppUpdateService? appUpdateService,
  })  : _appUpdateService = appUpdateService ?? appLocator<AppUpdateService>(),
        _eventController = StreamController<UiEvent>.broadcast();

  static const String _appName = oneTJAppName;
  static const String _version = oneTJAppVersion;
  static const String _buildNumber = oneTJAppBuildNumber;
  final AppUpdateService _appUpdateService;
  final StreamController<UiEvent> _eventController;
  bool _isCheckingUpdate = false;

  String get appName => _appName;
  String get version => _version;
  String get buildNumber => _buildNumber;
  Stream<UiEvent> get events => _eventController.stream;
  bool get isCheckingUpdate => _isCheckingUpdate;
  bool get isUpdateBusy => _isCheckingUpdate;

  Future<void> checkForUpdateManually() async {
    if (_isCheckingUpdate) {
      return;
    }
    _isCheckingUpdate = true;
    notifyListeners();
    try {
      final AppUpdateCheckResult result =
          await _appUpdateService.checkForUpdate(
        force: true,
      );
      if (!result.hasUpdate || result.updateInfo == null) {
        _eventController.add(const AppUpdateAlreadyLatestEvent());
        return;
      }
      _eventController.add(
        AppUpdateAvailableEvent(
          updateInfo: result.updateInfo!,
          fromManualCheck: true,
        ),
      );
    } catch (error, stackTrace) {
      _appUpdateService.logUpdateFailure(error, stackTrace);
      _eventController.add(
        AppUpdateFailedEvent(error: error, stackTrace: stackTrace),
      );
    } finally {
      _isCheckingUpdate = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
