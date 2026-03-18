import 'dart:async';

import 'package:onetj/models/base_model.dart';
import 'package:onetj/models/event_model.dart';
import 'package:onetj/models/launch_wallpaper_item.dart';
import 'package:onetj/features/settings/models/launch_wallpaper_editor_result.dart';
import 'package:onetj/services/launch_wallpaper_file_service.dart';

class LaunchWallpaperEditorUiState {
  const LaunchWallpaperEditorUiState({
    required this.loading,
    required this.busy,
    required this.wallpapers,
    required this.selectedWallpaperId,
    required this.selectedWallpaperPath,
  });

  final bool loading;
  final bool busy;
  final List<LaunchWallpaperItem> wallpapers;
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
  bool _loading = true;
  bool _busy = false;
  int _pathResolveVersion = 0;

  Stream<UiEvent> get events => _eventController.stream;

  LaunchWallpaperEditorUiState get uiState => LaunchWallpaperEditorUiState(
        loading: _loading,
        busy: _busy,
        wallpapers: List<LaunchWallpaperItem>.unmodifiable(_wallpapers),
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
        await _setSelectedWallpaperId(selectedId);
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
      // TODO: 详细提示
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
      // TODO: 显示繁忙提示
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
    _setSelectedWallpaperId(wallpaperId).then((_) {
      notifyListeners();
    });
  }

  Future<void> resetToDefault() async {
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
    if (_draftSelectedWallpaperId != null &&
        !_wallpapers.any((item) => item.id == _draftSelectedWallpaperId)) {
      _draftSelectedWallpaperId = null;
    }
    await _resolveSelectedWallpaperPath();
  }

  Future<void> _setSelectedWallpaperId(String? value) async {
    _draftSelectedWallpaperId = value;
    await _resolveSelectedWallpaperPath();
  }

  /// 设置选中的壁纸路径
  /// 
  /// 当解析完成后，若版本号与当前版本号不一致，则说明有其他操作已更新选中的壁纸，
  /// 则不更新当前选中的壁纸路径。
  Future<void> _resolveSelectedWallpaperPath() async {
    final int version = ++_pathResolveVersion;
    final String? selectedId = _draftSelectedWallpaperId;
    if (selectedId == null || selectedId.isEmpty) {
      _selectedWallpaperPath = null;
      return;
    }
    final String? path =
        await LaunchWallpaperFileService.resolveWallpaperPathById(selectedId);
    if (version != _pathResolveVersion) {
      return;
    }
    _selectedWallpaperPath = path;
  }

  @override
  void dispose() {
    _eventController.close();
    super.dispose();
  }
}
