import 'dart:async';

import 'package:onetj/features/settings/models/launch_wallpaper_editor_result.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/launch_wallpaper_item.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';

class LaunchWallpaperEditorUiState {
  const LaunchWallpaperEditorUiState({
    required this.loading,
    required this.busy,
    required this.wallpapers,
    required this.wallpaperPathById,
    required this.selectedWallpaperId,
    required this.selectedWallpaperPath,
  });

  final bool loading;
  final bool busy;
  final List<LaunchWallpaperItem> wallpapers;
  final Map<String, String> wallpaperPathById;
  final String? selectedWallpaperId;
  final String? selectedWallpaperPath;
}

class LaunchWallpaperEditorViewModel extends BaseViewModel {
  LaunchWallpaperEditorViewModel({
    required String? initialSelectedWallpaperId,
  })  : _initialSelectedWallpaperId = initialSelectedWallpaperId,
        _draftSelectedWallpaperId = initialSelectedWallpaperId;

  final StreamController<UiEvent> _eventController =
      StreamController<UiEvent>.broadcast();
  final String? _initialSelectedWallpaperId;

  String? _draftSelectedWallpaperId;
  String? _selectedWallpaperPath;
  List<LaunchWallpaperItem> _wallpapers = <LaunchWallpaperItem>[];
  /// 快速映射壁纸ID到路径
  Map<String, String> _wallpaperPathById = <String, String>{};
  bool _loading = true;
  bool _busy = false;

  Stream<UiEvent> get events => _eventController.stream;

  LaunchWallpaperEditorUiState get uiState => LaunchWallpaperEditorUiState(
        loading: _loading,
        busy: _busy,
        wallpapers: List<LaunchWallpaperItem>.unmodifiable(_wallpapers),
        wallpaperPathById: Map<String, String>.unmodifiable(_wallpaperPathById),
        selectedWallpaperId: _draftSelectedWallpaperId,
        selectedWallpaperPath: _selectedWallpaperPath,
      );

  Future<void> initialize() async {
    try {
      await _refreshWallpapers();
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to load launch wallpapers: $error'),
      );
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> pickFromGallery() async {
    if (_busy) {
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      final String? selectedId =
          await LaunchWallpaperFileService.importFromGallery();
      await _refreshWallpapers();
      if (selectedId != null) {
        _draftSelectedWallpaperId = selectedId;
        _selectedWallpaperPath = _wallpaperPathById[selectedId];
      }
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to select launch wallpaper: $error'),
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> renameWallpaper({
    required String wallpaperId,
    required String displayName,
  }) async {
    final String trimmed = displayName.trim();
    if (trimmed.isEmpty || _busy) {
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      await LaunchWallpaperFileService.renameWallpaper(
        wallpaperId: wallpaperId,
        displayName: trimmed,
      );
      await _refreshWallpapers();
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to rename launch wallpaper: $error'),
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> deleteWallpaper(String wallpaperId) async {
    if (_busy) {
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      await LaunchWallpaperFileService.deleteWallpaper(wallpaperId);
      await _refreshWallpapers();
    } catch (error) {
      _eventController.add(
        ShowSnackBarEvent(message: 'Failed to delete launch wallpaper: $error'),
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void selectWallpaper(String wallpaperId) {
    if (_draftSelectedWallpaperId == wallpaperId || _busy) {
      return;
    }
    _draftSelectedWallpaperId = wallpaperId;
    _selectedWallpaperPath = _wallpaperPathById[wallpaperId];
    notifyListeners();
  }

  void resetToDefault() {
    if (_draftSelectedWallpaperId == null || _busy) {
      return;
    }
    _draftSelectedWallpaperId = null;
    _selectedWallpaperPath = null;
    notifyListeners();
  }

  LaunchWallpaperEditorResult buildResult() {
    if (_draftSelectedWallpaperId == _initialSelectedWallpaperId) {
      return const LaunchWallpaperEditorResult.unchanged();
    }
    final String? selectedId = _draftSelectedWallpaperId;
    if (selectedId == null) {
      return const LaunchWallpaperEditorResult.resetToDefault();
    }
    return LaunchWallpaperEditorResult.selectedCustom(selectedId);
  }

  /// 刷新当前壁纸
  /// 
  /// 若当前选中的壁纸不在列表中，则将当前选中的壁纸ID设为null。
  Future<void> _refreshWallpapers() async {
    final List<LaunchWallpaperItem> items =
        await LaunchWallpaperFileService.listWallpapers();
    _wallpapers = items;
    _wallpaperPathById = await _buildWallpaperPathById(items);
    if (_draftSelectedWallpaperId != null &&
        !_wallpapers.any((item) => item.id == _draftSelectedWallpaperId)) {
      _draftSelectedWallpaperId = null;
    }
    final String? selectedId = _draftSelectedWallpaperId;
    _selectedWallpaperPath =
        selectedId == null ? null : _wallpaperPathById[selectedId];
  }

  Future<Map<String, String>> _buildWallpaperPathById(
    List<LaunchWallpaperItem> items,
  ) async {
    final List<MapEntry<String, String?>> entries = await Future.wait(
      items.map((item) async {
        final String? path =
            await LaunchWallpaperFileService.resolveWallpaperPathByFileName(
          item.fileName,
        );
        return MapEntry<String, String?>(item.id, path);
      }),
    );
    final Map<String, String> result = <String, String>{};
    for (final MapEntry<String, String?> entry in entries) {
      final String? value = entry.value;
      if (value == null || value.isEmpty) {
        continue;
      }
      result[entry.key] = value;
    }
    return result;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
