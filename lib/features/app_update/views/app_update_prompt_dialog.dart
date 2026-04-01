import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/app_update/models/event.dart';
import 'package:onetj/features/app_update/view_models/app_update_prompt_view_model.dart';
import 'package:onetj/models/app_update_info.dart';
import 'package:onetj/models/event_model.dart';

enum AppUpdatePromptDialogResult {
  later,
  updateNow,
  skipped,
}

class AppUpdatePromptDialog extends StatefulWidget {
  const AppUpdatePromptDialog({
    super.key,
    required this.updateInfo,
    required this.allowSkipVersion,
    required this.releaseNotes,
    required this.viewModel,
  });

  final AppUpdateInfo updateInfo;
  final bool allowSkipVersion;
  final String releaseNotes;
  final AppUpdatePromptViewModel viewModel;

  @override
  State<AppUpdatePromptDialog> createState() => _AppUpdatePromptDialogState();
}

class _AppUpdatePromptDialogState extends State<AppUpdatePromptDialog> {
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _eventSub = widget.viewModel.events.listen((UiEvent event) {
      if (!mounted) {
        return;
      }
      if (event is AppUpdateSkipVersionFailedEvent) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.appUpdateFailed(event.error.toString())),
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

  Future<void> _handleSkipVersion() async {
    final bool skipped =
        await widget.viewModel.skipVersion(widget.updateInfo.versionTag);
    if (!mounted || !skipped) {
      return;
    }
    Navigator.of(context).pop(AppUpdatePromptDialogResult.skipped);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (BuildContext context, _) {
        return AlertDialog(
          title: Text(l10n.appUpdateDialogTitle(widget.updateInfo.versionTag)),
          content: Text(
            widget.releaseNotes.isEmpty
                ? l10n.appUpdateNotesEmpty
                : widget.releaseNotes,
          ),
          actions: [
            TextButton(
              onPressed: widget.viewModel.busy
                  ? null
                  : () => Navigator.of(context).pop(
                        AppUpdatePromptDialogResult.later,
                      ),
              child: Text(l10n.appUpdateLater),
            ),
            if (widget.allowSkipVersion)
              TextButton(
                onPressed: widget.viewModel.skipping ? null : _handleSkipVersion,
                child: widget.viewModel.skipping
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.appUpdateSkipVersion),
              ),
            FilledButton(
              onPressed: widget.viewModel.busy
                  ? null
                  : () => Navigator.of(context).pop(
                        AppUpdatePromptDialogResult.updateNow,
                      ),
              child: Text(l10n.appUpdateNow),
            ),
          ],
        );
      },
    );
  }
}
