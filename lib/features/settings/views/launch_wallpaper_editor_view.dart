import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/settings/models/launch_wallpaper_editor_result.dart';
import 'package:onetj/features/settings/view_models/launch_wallpaper_editor_view_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/launch_wallpaper_item.dart';

class LaunchWallpaperEditorView extends StatefulWidget {
  const LaunchWallpaperEditorView({
    super.key,
    required this.initialSelectedWallpaperId,
  });

  final String? initialSelectedWallpaperId;

  @override
  State<LaunchWallpaperEditorView> createState() =>
      _LaunchWallpaperEditorViewState();
}

class _LaunchWallpaperEditorViewState extends State<LaunchWallpaperEditorView> {
  late final LaunchWallpaperEditorViewModel _viewModel;
  StreamSubscription<UiEvent>? _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = LaunchWallpaperEditorViewModel(
      initialSelectedWallpaperId: widget.initialSelectedWallpaperId,
    );
    _eventSub = _viewModel.events.listen((event) {
      if (!mounted || event is! ShowSnackBarEvent) {
        return;
      }
      final String message = event.message ?? '';
      if (message.isEmpty) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onRenameWallpaper(LaunchWallpaperItem item) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextEditingController controller =
        TextEditingController(text: item.displayName);
    final String? nextName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLaunchWallpaperRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: l10n.settingsLaunchWallpaperRenameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.saveLabel),
          ),
        ],
      ),
    );
    if (!mounted || nextName == null || nextName.isEmpty) {
      return;
    }
    await _viewModel.renameWallpaper(
      wallpaperId: item.id,
      displayName: nextName,
    );
  }

  Future<void> _onDeleteWallpaper(LaunchWallpaperItem item) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLaunchWallpaperDeleteTitle),
        content: Text(
          l10n.settingsLaunchWallpaperDeleteBody(item.displayName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.settingsLaunchWallpaperDeleteAction),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) {
      return;
    }
    await _viewModel.deleteWallpaper(item.id);
  }

  void _popWithResult() {
    final LaunchWallpaperEditorResult result = _viewModel.buildResult();
    Navigator.of(context).pop(result);
  }

  Widget _buildPreviewCard(
    AppLocalizations l10n,
    LaunchWallpaperEditorUiState state,
  ) {
    final String? selectedId = state.selectedWallpaperId;
    final String? selectedPath = state.selectedWallpaperPath;
    if (selectedId == null) {
      return _WallpaperPreviewPlaceholder(
        icon: Icons.wallpaper_outlined,
        title: l10n.settingsLaunchWallpaperDefaultSummary,
      );
    }
    if (selectedPath == null) {
      return _WallpaperPreviewPlaceholder(
        icon: Icons.hourglass_top,
        title: l10n.settingsLaunchWallpaperLoadingPreview,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(
        File(selectedPath),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _WallpaperPreviewPlaceholder(
            icon: Icons.broken_image_outlined,
            title: l10n.settingsLaunchWallpaperCustomSummary,
          );
        },
      ),
    );
  }

  Widget _buildWallpaperLibraryCard(
    AppLocalizations l10n,
    LaunchWallpaperEditorUiState state,
  ) {
    final List<LaunchWallpaperItem> wallpapers = state.wallpapers;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: wallpapers.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.settingsLaunchWallpaperLibraryEmpty),
              )
            : Column(
                children: wallpapers.map((item) {
                  final bool isSelected = item.id == state.selectedWallpaperId;
                  return ListTile(
                    enabled: !state.busy,
                    leading: Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(item.displayName),
                    subtitle: Text(item.fileName),
                    onTap: () => _viewModel.selectWallpaper(item.id),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'rename') {
                          _onRenameWallpaper(item);
                          return;
                        }
                        if (value == 'delete') {
                          _onDeleteWallpaper(item);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'rename',
                          child: Text(l10n.settingsLaunchWallpaperRenameAction),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(l10n.settingsLaunchWallpaperDeleteAction),
                        ),
                      ],
                    ),
                  );
                }).toList(growable: false),
              ),
      ),
    );
  }

  Widget _buildCurrentWallpaperCard(
    AppLocalizations l10n,
    LaunchWallpaperEditorUiState state,
  ) {
    final bool useDefaultWallpaper = state.selectedWallpaperId == null;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsLaunchWallpaperEditorCurrentTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildPreviewCard(l10n, state),
            const SizedBox(height: 8),
            Text(
              useDefaultWallpaper
                  ? l10n.settingsLaunchWallpaperDefaultSummary
                  : l10n.settingsLaunchWallpaperCustomSummary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return PopScope<LaunchWallpaperEditorResult?>(
      canPop: false,
      onPopInvokedWithResult:
          (bool didPop, LaunchWallpaperEditorResult? result) {
        if (didPop) {
          return;
        }
        _popWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithResult,
          ),
          title: Text(l10n.settingsLaunchWallpaperTitle),
        ),
        body: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            final LaunchWallpaperEditorUiState state = _viewModel.uiState;
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildCurrentWallpaperCard(l10n, state),
                const SizedBox(height: 12),
                _buildWallpaperLibraryCard(l10n, state),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.photo_library_outlined,
                  title: l10n.settingsLaunchWallpaperPickAction,
                  subtitle: l10n.settingsLaunchWallpaperPickSubtitle,
                  onTap: state.busy ? () {} : _viewModel.pickFromGallery,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.restore,
                  title: l10n.settingsLaunchWallpaperResetAction,
                  subtitle: l10n.settingsLaunchWallpaperResetSubtitle,
                  onTap: state.busy ? () {} : _viewModel.resetToDefault,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WallpaperPreviewPlaceholder extends StatelessWidget {
  const _WallpaperPreviewPlaceholder({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surfaceContainerHighest,
            Theme.of(context).colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Text(title),
        ],
      ),
    );
  }
}
