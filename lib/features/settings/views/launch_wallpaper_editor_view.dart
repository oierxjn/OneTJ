import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/settings/models/launch_wallpaper_editor_result.dart';
import 'package:onetj/features/settings/view_models/launch_wallpaper_editor_view_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/launch_wallpaper_item.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';

class LaunchWallpaperEditorView extends StatefulWidget {
  const LaunchWallpaperEditorView({
    super.key,
    required this.initialSelectedWallpaperRef,
  });

  final LaunchWallpaperRef initialSelectedWallpaperRef;

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
      initialSelectedWallpaperRef: widget.initialSelectedWallpaperRef,
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

  Widget _buildCurrentPreviewCard(
    AppLocalizations l10n,
    LaunchWallpaperEditorUiState state,
  ) {
    final bool useDefaultWallpaper = state.selectedWallpaperRef.isBuiltin;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsLaunchWallpaperEditorCurrentTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildPreviewContent(l10n, state),
              ),
            ),
            const SizedBox(height: 10),
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

  Widget _buildPreviewContent(
    AppLocalizations l10n,
    LaunchWallpaperEditorUiState state,
  ) {
    final String? selectedPath = state.selectedWallpaperPath;
    final LaunchWallpaperItem? selectedItem = state.selectedWallpaperItem;
    if (selectedItem == null) {
      return _WallpaperPreviewPlaceholder(
        icon: Icons.wallpaper_outlined,
        title: l10n.settingsLaunchWallpaperDefaultSummary,
      );
    }
    return _buildWallpaperPreviewImage(
      l10n: l10n,
      item: selectedItem,
      path: selectedPath,
    );
  }

  Widget _buildWallpaperPreviewImage({
    required AppLocalizations l10n,
    required LaunchWallpaperItem item,
    required String? path,
  }) {
    final bool isBuiltin =
        item.source == LaunchWallpaperFileService.builtinSource;
    if (path == null) {
      if (!isBuiltin) {
        return _buildUnsupportedImagePlaceholder(l10n);
      }
      final String? assetPath = item.assetPath;
      if (assetPath == null || assetPath.isEmpty) {
        return _buildBrokenImagePlaceholder(l10n);
      }
      return Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildBrokenImagePlaceholder(l10n);
        },
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildBrokenImagePlaceholder(l10n);
      },
    );
  }

  Widget _buildBrokenImagePlaceholder(AppLocalizations l10n) {
    return _WallpaperPreviewPlaceholder(
      icon: Icons.broken_image_outlined,
      title: l10n.settingsLaunchWallpaperPreviewLoadFailed,
    );
  }

  Widget _buildUnsupportedImagePlaceholder(AppLocalizations l10n) {
    return _WallpaperPreviewPlaceholder(
      icon: Icons.image_not_supported_outlined,
      title: l10n.settingsLaunchWallpaperPreviewUnavailable,
    );
  }

  Widget _buildGridSection(
    AppLocalizations l10n,
    LaunchWallpaperEditorUiState state,
  ) {
    final List<LaunchWallpaperItem> wallpapers = state.wallpapers;
    if (wallpapers.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          child: Text(l10n.settingsLaunchWallpaperLibraryEmpty),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: wallpapers.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final LaunchWallpaperItem item = wallpapers[index];
        final bool selected = item.id == state.selectedWallpaperRef.id;
        final String? path = state.wallpaperPathById[item.id];
        return _buildWallpaperTile(
          l10n: l10n,
          item: item,
          selected: selected,
          path: path,
          busy: state.busy,
        );
      },
    );
  }

  Widget _buildWallpaperTile({
    required AppLocalizations l10n,
    required LaunchWallpaperItem item,
    required bool selected,
    required String? path,
    required bool busy,
  }) {
    final bool isBuiltin =
        item.source == LaunchWallpaperFileService.builtinSource;
    return InkWell(
      onTap: busy ? null : () => _viewModel.selectWallpaper(item.id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 2.2 : 1,
          ),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: _buildWallpaperPreviewImage(
                            l10n: l10n,
                            item: item,
                            path: path,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Row(
                      children: [
                        PopupMenuButton<String>(
                          enabled: !busy,
                          icon: const Icon(Icons.more_vert, size: 18),
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
                              child: Text(
                                  l10n.settingsLaunchWallpaperRenameAction),
                            ),
                            if (!isBuiltin)
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text(
                                    l10n.settingsLaunchWallpaperDeleteAction),
                              ),
                          ],
                        ),
                        if (selected)
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Text(
                item.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
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
          actions: [
            IconButton(
              tooltip: l10n.settingsLaunchWallpaperPickAction,
              onPressed: () {
                final LaunchWallpaperEditorUiState state = _viewModel.uiState;
                if (state.busy) {
                  return;
                }
                _viewModel.pickFromGallery();
              },
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
            IconButton(
              tooltip: l10n.settingsLaunchWallpaperResetAction,
              onPressed: () {
                final LaunchWallpaperEditorUiState state = _viewModel.uiState;
                if (state.busy) {
                  return;
                }
                _viewModel.resetToDefault();
              },
              icon: const Icon(Icons.restore),
            ),
          ],
        ),
        body: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            final LaunchWallpaperEditorUiState state = _viewModel.uiState;
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildCurrentPreviewCard(l10n, state),
                const SizedBox(height: 12),
                _buildGridSection(l10n, state),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
