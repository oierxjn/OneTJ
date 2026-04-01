import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/app/di/dependencies.dart';
import 'package:onetj/app/constant/app_version_constant.dart';
import 'package:onetj/features/app_update/models/event.dart';
import 'package:onetj/features/app_update/models/app_update_flow_state.dart';
import 'package:onetj/features/app_update/view_models/app_update_flow_view_model.dart';
import 'package:onetj/features/app_update/view_models/app_update_migration_view_model.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/services/app_update_service.dart';
import 'package:onetj/services/external_launcher_service.dart';

Future<void> showAppUpdateFlow(
  BuildContext context, {
  required AppUpdateInfo updateInfo,
  required bool allowSkipVersion,
  AppUpdateService? appUpdateService,
}) async {
  final AppUpdateService service =
      appUpdateService ?? appLocator<AppUpdateService>();
  final AppLocalizations l10n = AppLocalizations.of(context);
  final ExternalLauncherService externalLauncherService =
      appLocator<ExternalLauncherService>();
  if (service.requiresMigration(updateInfo)) {
    await _showMigrationFlow(
      context,
      updateInfo: updateInfo,
      migrationViewModel: AppUpdateMigrationViewModel(
        externalLauncherService: externalLauncherService,
      ),
      canDownloadNow:
          externalLauncherService.isValidExternalUrl(updateInfo.downloadUrl),
    );
    return;
  }
  final String notes = service.formatReleaseNotes(updateInfo);
  bool skipping = false;
  final bool? updateNow = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (BuildContext dialogContext, StateSetter setState) {
          // TODO: 逻辑比较像viewmodel，可能需要下沉
          Future<void> handleSkipVersion() async {
            if (skipping) {
              return;
            }
            setState(() {
              skipping = true;
            });
            try {
              await service.skipVersion(updateInfo.versionTag);
              if (!dialogContext.mounted) {
                return;
              }
              Navigator.of(dialogContext).pop(false);
            } catch (error, stackTrace) {
              service.logUpdateFailure(error, stackTrace);
              if (!dialogContext.mounted) {
                return;
              }
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  content: Text(l10n.appUpdateFailed(error.toString())),
                ),
              );
            } finally {
              if (dialogContext.mounted) {
                setState(() {
                  skipping = false;
                });
              }
            }
          }

          return AlertDialog(
            title: Text(l10n.appUpdateDialogTitle(updateInfo.versionTag)),
            content: Text(
              notes.isEmpty ? l10n.appUpdateNotesEmpty : notes,
            ),
            actions: [
              TextButton(
                onPressed: skipping
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.appUpdateLater),
              ),
              if (allowSkipVersion)
                TextButton(
                  onPressed: skipping ? null : handleSkipVersion,
                  child: skipping
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.appUpdateSkipVersion),
                ),
              FilledButton(
                onPressed: skipping
                    ? null
                    : () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.appUpdateNow),
              ),
            ],
          );
        },
      );
    },
  );
  if (updateNow != true || !context.mounted) {
    return;
  }

  final AppUpdateFlowViewModel viewModel = AppUpdateFlowViewModel(
    appUpdateService: service,
  );
  final AppUpdateFlowCompletion? completion =
      await showDialog<AppUpdateFlowCompletion>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AppUpdateDownloadDialog(
        updateInfo: updateInfo,
        viewModel: viewModel,
      );
    },
  );
  viewModel.dispose();

  if (!context.mounted || completion == null) {
    return;
  }
  switch (completion.type) {
    case AppUpdateFlowCompletionType.installerStarted:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appUpdateInstallTriggered)),
      );
      break;
    case AppUpdateFlowCompletionType.permissionRequired:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appUpdateInstallPermissionRequired)),
      );
      break;
    case AppUpdateFlowCompletionType.failed:
      final Object error = completion.error ?? 'unknown';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appUpdateFailed(error.toString()))),
      );
      break;
  }
}

Future<void> _showMigrationFlow(
  BuildContext context, {
  required AppUpdateInfo updateInfo,
  required AppUpdateMigrationViewModel migrationViewModel,
  required bool canDownloadNow,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final StreamSubscription<UiEvent> eventSub =
      migrationViewModel.events.listen((UiEvent event) {
        if (!context.mounted) {
          return;
        }
        if (event is AppUpdateMigrationLinkCopiedEvent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.appUpdateMigrationLinkCopied)),
          );
          return;
        }
        if (event is AppUpdateMigrationLinkCopyFailedEvent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.appUpdateFailed(event.error.toString()),
              ),
            ),
          );
          return;
        }
        if (event is AppUpdateMigrationDownloadOpenFailedEvent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.appUpdateMigrationOpenDownloadFailed(event.url),
              ),
            ),
          );
        }
      });
  try {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AnimatedBuilder(
          animation: migrationViewModel,
          builder: (BuildContext dialogContext, _) {
            return AlertDialog(
              title: Text(
                l10n.appUpdateMigrationTitle(updateInfo.versionTag),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appUpdateMigrationSummary(oneTJAppVersion),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appUpdateMigrationStepsTitle,
                      style: Theme.of(dialogContext).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.appUpdateMigrationStepDownload),
                    const SizedBox(height: 4),
                    Text(l10n.appUpdateMigrationStepLocate),
                    const SizedBox(height: 4),
                    Text(l10n.appUpdateMigrationStepUninstall),
                    const SizedBox(height: 4),
                    Text(l10n.appUpdateMigrationStepInstall),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appUpdateMigrationRisk,
                      style: Theme.of(dialogContext).textTheme.bodySmall,
                    ),
                    if (updateInfo.downloadUrl.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SelectableText(
                        updateInfo.downloadUrl,
                        style: Theme.of(dialogContext).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.appUpdateLater),
                ),
                TextButton(
                  onPressed: migrationViewModel.copying
                      ? null
                      : () => migrationViewModel.copyLink(updateInfo.downloadUrl),
                  child: migrationViewModel.copying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.appUpdateMigrationCopyLink),
                ),
                FilledButton(
                  onPressed: !canDownloadNow || migrationViewModel.opening
                      ? null
                      : () => migrationViewModel.downloadNow(
                            updateInfo.downloadUrl,
                          ),
                  child: migrationViewModel.opening
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.appUpdateMigrationDownloadNow),
                ),
              ],
            );
          },
        );
      },
    );
  } finally {
    await eventSub.cancel();
    migrationViewModel.dispose();
  }
}

class AppUpdateDownloadDialog extends StatefulWidget {
  const AppUpdateDownloadDialog({
    super.key,
    required this.updateInfo,
    required this.viewModel,
  });

  final AppUpdateInfo updateInfo;
  final AppUpdateFlowViewModel viewModel;

  @override
  State<AppUpdateDownloadDialog> createState() =>
      _AppUpdateDownloadDialogState();
}

class _AppUpdateDownloadDialogState extends State<AppUpdateDownloadDialog> {
  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    final AppUpdateFlowCompletion completion =
        await widget.viewModel.run(widget.updateInfo);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(completion);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (BuildContext context, _) {
        final AppUpdateFlowState state = widget.viewModel.state;
        final double? progress = state.progress;
        final String phaseText = switch (state.phase) {
          AppUpdateFlowPhase.verifying => l10n.appUpdateVerifyingBody,
          AppUpdateFlowPhase.installing => l10n.appUpdateInstallingBody,
          _ => l10n.appUpdateDownloadingBody,
        };
        final String bytesText = _buildBytesText(l10n, state);
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(l10n.appUpdateDownloadingTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phaseText),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                if (progress != null)
                  Text(
                    '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 4),
                Text(
                  bytesText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildBytesText(AppLocalizations l10n, AppUpdateFlowState state) {
    final String received = _formatBytes(state.receivedBytes);
    final int? totalBytes = state.totalBytes;
    if (totalBytes == null || totalBytes <= 0) {
      return l10n.appUpdateDownloadedBytesUnknown(received);
    }
    return l10n.appUpdateDownloadedBytesKnown(
      received,
      _formatBytes(totalBytes),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    double value = bytes.toDouble();
    int unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    final String formatted = value >= 100 || unitIndex == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$formatted ${units[unitIndex]}';
  }
}
