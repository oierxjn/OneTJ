import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/app/constant/app_version_constant.dart';
import 'package:onetj/features/app_update/models/event.dart';
import 'package:onetj/features/app_update/view_models/app_update_migration_view_model.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/event_model.dart';

class AppUpdateMigrationDialog extends StatefulWidget {
  const AppUpdateMigrationDialog({
    super.key,
    required this.updateInfo,
    required this.canDownloadNow,
    required this.viewModel,
  });

  final AppUpdateInfo updateInfo;
  final bool canDownloadNow;
  final AppUpdateMigrationViewModel viewModel;

  @override
  State<AppUpdateMigrationDialog> createState() =>
      _AppUpdateMigrationDialogState();
}

class _AppUpdateMigrationDialogState extends State<AppUpdateMigrationDialog> {
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub = widget.viewModel.events.listen((UiEvent event) {
      if (!mounted) {
        return;
      }
      final AppLocalizations l10n = AppLocalizations.of(context);
      if (event is AppUpdateMigrationLinkCopiedEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.appUpdateMigrationLinkCopied)),
        );
        return;
      }
      if (event is AppUpdateMigrationLinkCopyFailedEvent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appUpdateFailed(event.error.toString())),
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
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (BuildContext context, _) {
        return AlertDialog(
          title: Text(
            l10n.appUpdateMigrationTitle(widget.updateInfo.versionTag),
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
                  style: Theme.of(context).textTheme.titleSmall,
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
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (widget.updateInfo.downloadUrl.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    widget.updateInfo.downloadUrl,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.appUpdateLater),
            ),
            TextButton(
              onPressed: widget.viewModel.copying
                  ? null
                  : () => widget.viewModel.copyLink(widget.updateInfo.downloadUrl),
              child: widget.viewModel.copying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.appUpdateMigrationCopyLink),
            ),
            FilledButton(
              onPressed: !widget.canDownloadNow || widget.viewModel.opening
                  ? null
                  : () => widget.viewModel.downloadNow(
                        widget.updateInfo.downloadUrl,
                      ),
              child: widget.viewModel.opening
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
  }
}
