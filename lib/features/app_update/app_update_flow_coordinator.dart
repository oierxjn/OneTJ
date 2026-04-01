import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/features/app_update/view_models/app_update_flow_view_model.dart';
import 'package:onetj/features/app_update/view_models/app_update_migration_view_model.dart';
import 'package:onetj/features/app_update/view_models/app_update_prompt_view_model.dart';
import 'package:onetj/features/app_update/views/app_update_download_dialog.dart';
import 'package:onetj/features/app_update/views/app_update_migration_dialog.dart';
import 'package:onetj/features/app_update/views/app_update_prompt_dialog.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/external_launcher_service.dart';

class AppUpdateFlowCoordinator {
  AppUpdateFlowCoordinator({
    AppUpdateService? appUpdateService,
    ExternalLauncherService? externalLauncherService,
  })  : _appUpdateService = appUpdateService ?? appLocator<AppUpdateService>(),
        _externalLauncherService = externalLauncherService ??
            appLocator<ExternalLauncherService>();

  final AppUpdateService _appUpdateService;
  final ExternalLauncherService _externalLauncherService;

  Future<void> run(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    required bool allowSkipVersion,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_appUpdateService.requiresMigration(updateInfo)) {
      await _showMigrationDialog(
        context,
        updateInfo: updateInfo,
      );
      return;
    }

    final AppUpdatePromptDialogResult? promptResult = await _showPromptDialog(
      context,
      updateInfo: updateInfo,
      allowSkipVersion: allowSkipVersion,
    );
    if (!context.mounted ||
        promptResult != AppUpdatePromptDialogResult.updateNow) {
      return;
    }

    final AppUpdateFlowCompletion? completion = await _showDownloadDialog(
      context,
      updateInfo: updateInfo,
    );
    if (!context.mounted || completion == null) {
      return;
    }

    switch (completion.type) {
      case AppUpdateFlowCompletionType.installerStarted:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.appUpdateInstallTriggered)),
        );
        return;
      case AppUpdateFlowCompletionType.permissionRequired:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.appUpdateInstallPermissionRequired)),
        );
        return;
      case AppUpdateFlowCompletionType.failed:
        final Object error = completion.error ?? 'unknown';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.appUpdateFailed(error.toString()))),
        );
        return;
    }
  }

  Future<AppUpdatePromptDialogResult?> _showPromptDialog(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
    required bool allowSkipVersion,
  }) async {
    final AppUpdatePromptViewModel viewModel = AppUpdatePromptViewModel(
      appUpdateService: _appUpdateService,
    );
    try {
      return await showDialog<AppUpdatePromptDialogResult>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AppUpdatePromptDialog(
            updateInfo: updateInfo,
            allowSkipVersion: allowSkipVersion,
            releaseNotes: _appUpdateService.formatReleaseNotes(updateInfo),
            viewModel: viewModel,
          );
        },
      );
    } finally {
      viewModel.dispose();
    }
  }

  Future<void> _showMigrationDialog(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
  }) async {
    final AppUpdateMigrationViewModel viewModel = AppUpdateMigrationViewModel(
      externalLauncherService: _externalLauncherService,
    );
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext dialogContext) {
          return AppUpdateMigrationDialog(
            updateInfo: updateInfo,
            canDownloadNow: _externalLauncherService.isValidExternalUrl(
              updateInfo.downloadUrl,
            ),
            viewModel: viewModel,
          );
        },
      );
    } finally {
      viewModel.dispose();
    }
  }

  Future<AppUpdateFlowCompletion?> _showDownloadDialog(
    BuildContext context, {
    required AppUpdateInfo updateInfo,
  }) async {
    final AppUpdateFlowViewModel viewModel = AppUpdateFlowViewModel(
      appUpdateService: _appUpdateService,
    );
    try {
      return await showDialog<AppUpdateFlowCompletion>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AppUpdateDownloadDialog(
            updateInfo: updateInfo,
            viewModel: viewModel,
          );
        },
      );
    } finally {
      viewModel.dispose();
    }
  }
}
