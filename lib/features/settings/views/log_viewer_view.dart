import 'dart:async';

import 'package:flutter/material.dart';
import 'package:onetj/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import 'package:onetj/app/logging/log_file_info.dart';
import 'package:onetj/features/settings/models/event.dart';
import 'package:onetj/features/settings/view_models/log_viewer_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';

class LogViewerView extends StatefulWidget {
  const LogViewerView({super.key});

  @override
  State<LogViewerView> createState() => _LogViewerViewState();
}

class _LogViewerViewState extends State<LogViewerView> {
  final ScrollController _scrollController = ScrollController();
  late final LogViewerViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = LogViewerViewModel();
    _eventSub = _viewModel.events.listen(_handleEvent);
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleEvent(UiEvent event) async {
    if (!mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (event is LogExportCanceledEvent) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsLogsExportCanceled)),
      );
      return;
    }
    if (event is LogExportFailedEvent) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsLogsExportFailed(event.message ?? ''),
          ),
        ),
      );
      return;
    }
    if (event is LogExportSucceededEvent) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsLogsExportSuccess(path.basename(event.path)),
          ),
          action: SnackBarAction(
            label: l10n.settingsLogsOpenFileAction,
            onPressed: () => _viewModel.openExportedFile(event.path),
          ),
        ),
      );
      return;
    }
    if (event is LogOpenFailedEvent) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsLogsOpenFileFailed(event.message ?? ''),
          ),
        ),
      );
      return;
    }
  }

  String _formatFileLabel(AppLogFileInfo file) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(file.date);
  }

  String _formatSize(AppLogFileInfo file) {
    final int size = file.sizeBytes;
    if (size < 1024) {
      return '$size B';
    }
    final double kb = size / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';
    }
    final double mb = kb / 1024;
    return '${mb.toStringAsFixed(mb >= 100 ? 0 : 1)} MB';
  }

  Widget _buildBody(AppLocalizations l10n, LogViewerUiState state) {
    if (state.loadingFiles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.filesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.settingsLogsLoadFailed(state.filesError!),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (state.files.isEmpty) {
      return Center(
        child: Text(l10n.settingsLogsEmpty),
      );
    }

    final AppLogFileInfo selectedFile = state.selectedFile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
          child: Card(
            child: ListTile(
              title: Text(_formatFileLabel(selectedFile)),
              subtitle: Text(
                '${selectedFile.name} | ${_formatSize(selectedFile)}'
                '${selectedFile.isCurrent ? ' | ${l10n.settingsLogsCurrentFileLabel}' : ''}',
              ),
            ),
          ),
        ),
        Expanded(
          child: state.loadingContent
              ? const Center(child: CircularProgressIndicator())
              : state.contentError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.settingsLogsLoadFailed(state.contentError!),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : (state.content == null || state.content!.trim().isEmpty)
                      ? Center(
                          child: Text(l10n.settingsLogsFileEmpty),
                        )
                      : Scrollbar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            child: SelectionArea(
                              child: SelectableText(
                                state.content!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                        ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final LogViewerUiState state = _viewModel.uiState;
        final bool canExport = !state.loadingFiles &&
            !state.loadingContent &&
            !state.exporting &&
            state.selectedFile != null;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settingsLogsTitle),
            actions: [
              IconButton(
                tooltip: MaterialLocalizations.of(context)
                    .refreshIndicatorSemanticLabel,
                onPressed: state.loadingFiles || state.exporting
                    ? null
                    : _viewModel.reloadFiles,
                icon: const Icon(Icons.refresh),
              ),
              if (state.selectedFile != null)
                IconButton(
                  tooltip: l10n.settingsLogsExportAction,
                  onPressed: canExport ? _viewModel.exportSelectedFile : null,
                  icon: state.exporting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt_outlined),
                ),
              if (state.files.isNotEmpty)
                PopupMenuButton<AppLogFileInfo>(
                  tooltip: l10n.settingsLogsSwitchFileAction,
                  enabled: !state.exporting,
                  icon: const Icon(Icons.folder_open_outlined),
                  initialValue: state.selectedFile,
                  onSelected: _viewModel.selectFile,
                  itemBuilder: (context) => state.files
                      .map(
                        (file) => PopupMenuItem<AppLogFileInfo>(
                          value: file,
                          child: Text(
                            file.isCurrent
                                ? '${_formatFileLabel(file)} (${l10n.settingsLogsCurrentFileLabel})'
                                : _formatFileLabel(file),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
            ],
          ),
          body: _buildBody(l10n, state),
        );
      },
    );
  }
}
