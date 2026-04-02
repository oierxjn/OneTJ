import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:onetj/app/logging/log_file_info.dart';
import 'package:onetj/app/logging/logger.dart';

class LogViewerView extends StatefulWidget {
  const LogViewerView({super.key});

  @override
  State<LogViewerView> createState() => _LogViewerViewState();
}

class _LogViewerViewState extends State<LogViewerView> {
  final ScrollController _scrollController = ScrollController();
  bool _loadingFiles = true;
  bool _loadingContent = false;
  List<AppLogFileInfo> _files = const <AppLogFileInfo>[];
  AppLogFileInfo? _selectedFile;
  String? _content;
  String? _filesError;
  String? _contentError;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _loadingFiles = true;
      _filesError = null;
    });
    try {
      final List<AppLogFileInfo> files = await AppLogger.listLogFiles();
      final AppLogFileInfo? nextSelected = files.isEmpty ? null : files.first;
      if (!mounted) {
        return;
      }
      setState(() {
        _files = files;
        _selectedFile = nextSelected;
        _loadingFiles = false;
        _content = null;
        _contentError = null;
      });
      if (nextSelected != null) {
        await _loadContent(nextSelected);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingFiles = false;
        _files = const <AppLogFileInfo>[];
        _selectedFile = null;
        _filesError = error.toString();
        _content = null;
        _contentError = null;
      });
    }
  }

  Future<void> _loadContent(AppLogFileInfo file) async {
    setState(() {
      _selectedFile = file;
      _loadingContent = true;
      _contentError = null;
    });
    try {
      final String text = await AppLogger.readLogFile(file.path);
      if (!mounted) {
        return;
      }
      setState(() {
        _content = text;
        _loadingContent = false;
      });
    } on FileSystemException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _content = null;
        _loadingContent = false;
        _contentError = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _content = null;
        _loadingContent = false;
        _contentError = error.toString();
      });
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

  Widget _buildBody(AppLocalizations l10n) {
    if (_loadingFiles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.settingsLogsLoadFailed(_filesError!),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_files.isEmpty) {
      return Center(
        child: Text(l10n.settingsLogsEmpty),
      );
    }

    final AppLogFileInfo selectedFile = _selectedFile!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Card(
            child: ListTile(
              title: Text(_formatFileLabel(selectedFile)),
              subtitle: Text(
                '${selectedFile.name} · ${_formatSize(selectedFile)}'
                '${selectedFile.isCurrent ? ' · ${l10n.settingsLogsCurrentFileLabel}' : ''}',
              ),
            ),
          ),
        ),
        Expanded(
          child: _loadingContent
              ? const Center(child: CircularProgressIndicator())
              : _contentError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.settingsLogsLoadFailed(_contentError!),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : (_content == null || _content!.trim().isEmpty)
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
                                _content!,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsLogsTitle),
        actions: [
          IconButton(
            tooltip:
                MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
            onPressed: _loadingFiles ? null : _loadFiles,
            icon: const Icon(Icons.refresh),
          ),
          if (_files.isNotEmpty)
            PopupMenuButton<AppLogFileInfo>(
              tooltip: l10n.settingsLogsSwitchFileAction,
              icon: const Icon(Icons.folder_open_outlined),
              initialValue: _selectedFile,
              onSelected: _loadContent,
              itemBuilder: (context) => _files
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
      body: _buildBody(l10n),
    );
  }
}
