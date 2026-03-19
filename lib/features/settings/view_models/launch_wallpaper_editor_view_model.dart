import 'dart:async';

import 'package:onetj/features/settings/models/launch_wallpaper_editor_result.dart';
import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/launch_wallpaper_item.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';

class LaunchWallpaperEditorUiState {
  const LaunchWallpaperEditorUiState({
    required this.loading,
    required this.busy,
    required this.wallpapers,
    required this.wallpaperPathById,
    required this.selectedWallpaperRef,
    required this.selectedWallpaperPath,
  });

  final bool loading;
  final bool busy;
  final List<LaunchWallpaperItem> wallpapers;
  final Map<String, String> wallpaperPathById;
  final LaunchWallpaperRef selectedWallpaperRef;
  final String? selectedWallpaperPath;
}

class LaunchWallpaperEditorViewModel extends BaseViewModel {
  LaunchWallpaperEditorViewModel({
    required LaunchWallpaperRef? initialSelectedWallpaperRef,
  })  : _initialSelectedWallpaperRef =
            initialSelectedWallpaperRef ?? LaunchWallpaperRef.defaultValue,
        _draftSelectedWallpaperRef =
            initialSelectedWallpaperRef ?? LaunchWallpaperRef.defaultValue;

  final StreamController<UiEvent> _eventController =
      StreamController<UiEvent>.broadcast();
  final LaunchWallpaperRef _initialSelectedWallpaperRef;

  LaunchWallpaperRef _draftSelectedWallpaperRef;
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
        selectedWallpaperRef: _draftSelectedWallpaperRef,
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
        _draftSelectedWallpaperRef = LaunchWallpaperRef(
          type: LaunchWallpaperRef.typeLocal,
          id: selectedId,
        );
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
    if (_draftSelectedWallpaperRef.id == wallpaperId || _busy) {
      return;
    }
    LaunchWallpaperItem? selectedItem;
    for (final LaunchWallpaperItem item in _wallpapers) {
      if (item.id == wallpaperId) {
        selectedItem = item;
        break;
      }
    }
    if (selectedItem == null) {
      return;
    }
    _draftSelectedWallpaperRef = _buildRefFromItem(selectedItem);
    _selectedWallpaperPath = _wallpaperPathById[wallpaperId];
    notifyListeners();
  }

  void resetToDefault() {
    if (_busy) {
      return;
    }
    _draftSelectedWallpaperRef = LaunchWallpaperRef.defaultValue;
    _selectedWallpaperPath = _wallpaperPathById[_draftSelectedWallpaperRef.id];
    notifyListeners();
  }

  LaunchWallpaperEditorResult buildResult() {
    if (_draftSelectedWallpaperRef == _initialSelectedWallpaperRef) {
      return const LaunchWallpaperEditorResult.unchanged();
    }
    return LaunchWallpaperEditorResult.selected(_draftSelectedWallpaperRef);
  }

  /// 刷新当前壁纸
  ///
  /// 若当前选中的壁纸不在列表中，则将当前选中的壁纸ID设为null。
  Future<void> _refreshWallpapers() async {
    final List<LaunchWallpaperItem> items =
        await LaunchWallpaperFileService.listWallpapers();
    _wallpapers = items;
    _wallpaperPathById = await _buildWallpaperPathById(items);
    if (!_wallpapers.any((item) => item.id == _draftSelectedWallpaperRef.id)) {
      _draftSelectedWallpaperRef = LaunchWallpaperRef.defaultValue;
    }
    _selectedWallpaperPath = _wallpaperPathById[_draftSelectedWallpaperRef.id];
  }

  Future<Map<String, String>> _buildWallpaperPathById(
    List<LaunchWallpaperItem> items,
  ) async {
    return LaunchWallpaperFileService.resolveWallpaperPathByIdBatch(items);
  }

  LaunchWallpaperRef _buildRefFromItem(LaunchWallpaperItem item) {
    if (item.source == LaunchWallpaperFileService.builtinSource) {
      return LaunchWallpaperRef(
        type: LaunchWallpaperRef.typeBuiltin,
        id: item.id,
      );
    }
    return LaunchWallpaperRef(
      type: LaunchWallpaperRef.typeLocal,
      id: item.id,
    );
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
