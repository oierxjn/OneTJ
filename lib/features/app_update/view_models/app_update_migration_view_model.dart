import 'package:flutter/services.dart';

import 'package:onetj/models/base_model.dart';
import 'package:onetj/services/external_launcher_service.dart';

enum AppUpdateMigrationActionResultType {
  launched,
  copied,
  failed,
}

class AppUpdateMigrationActionResult {
  const AppUpdateMigrationActionResult._({
    required this.type,
    this.url,
  });

  const AppUpdateMigrationActionResult.launched()
      : this._(type: AppUpdateMigrationActionResultType.launched);

  const AppUpdateMigrationActionResult.copied()
      : this._(type: AppUpdateMigrationActionResultType.copied);

  const AppUpdateMigrationActionResult.failed({
    required String url,
  }) : this._(
          type: AppUpdateMigrationActionResultType.failed,
          url: url,
        );

  final AppUpdateMigrationActionResultType type;
  final String? url;
}

class AppUpdateMigrationViewModel extends BaseViewModel<Never> {
  AppUpdateMigrationViewModel({
    ExternalLauncherService? externalLauncherService,
  }) : _externalLauncherService =
            externalLauncherService ?? ExternalLauncherService.getInstance();

  final ExternalLauncherService _externalLauncherService;

  bool _opening = false;
  bool _copying = false;

  bool get opening => _opening;
  bool get copying => _copying;

  Future<AppUpdateMigrationActionResult> openDownload(String url) async {
    if (_opening) {
      return AppUpdateMigrationActionResult.failed(url: url);
    }
    _opening = true;
    notifyListeners();
    try {
      final ExternalUrlLaunchResult result =
          await _externalLauncherService.openExternalUrl(url);
      switch (result) {
        case ExternalUrlLaunchResult.launched:
          return const AppUpdateMigrationActionResult.launched();
        case ExternalUrlLaunchResult.failed:
          return AppUpdateMigrationActionResult.failed(url: url);
      }
    } finally {
      _opening = false;
      notifyListeners();
    }
  }

  Future<AppUpdateMigrationActionResult> copyLink(String url) async {
    if (_copying) {
      return const AppUpdateMigrationActionResult.copied();
    }
    _copying = true;
    notifyListeners();
    try {
      await Clipboard.setData(ClipboardData(text: url));
      return const AppUpdateMigrationActionResult.copied();
    } finally {
      _copying = false;
      notifyListeners();
    }
  }
}
