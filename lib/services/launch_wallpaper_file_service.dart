import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:onetj/app/logging/logger.dart';
import 'package:onetj/models/launch_wallpaper_item.dart';
import 'package:onetj/models/launch_wallpaper_ref.dart';
import 'package:onetj/models/settings_defaults.dart';

class LaunchWallpaperResolved {
  const LaunchWallpaperResolved._({
    this.filePath,
    this.assetPath,
  });

  const LaunchWallpaperResolved.file(String filePath)
      : this._(filePath: filePath);

  const LaunchWallpaperResolved.asset(String assetPath)
      : this._(assetPath: assetPath);

  final String? filePath;
  final String? assetPath;
}

class LaunchWallpaperFileService {
  const LaunchWallpaperFileService._();

  static const String _folderName = 'wallpapers';
  static const String _indexFileName = 'index.json';
  static const String _filesFolderName = 'files';
  static const Uuid _uuid = Uuid();
  static const String builtinSource = 'builtin';
  static const String importedSource = 'gallery';
  static Future<Directory>? _cachedSupportDirectoryFuture;
  /// 缓存的用户自定义壁纸项索引
  static List<LaunchWallpaperItem>? _cachedIndexItems;
  /// 缓存的全部壁纸项索引
  static List<LaunchWallpaperItem>? _cachedMergedItems;
  static Map<String, String>? _cachedPathById;
  static bool _cacheDirty = true;
  static Future<void>? _cacheLoadingFuture;

  /// 内置壁纸项
  static const List<(String id, String name, String assetPath)> _builtinSeeds =
      [
    (
      kDefaultLaunchWallpaperId,
      'Built-in Wallpaper',
      kDefaultLaunchWallpaperAsset,
    ),
  ];

  static String get defaultWallpaperId => kDefaultLaunchWallpaperId;

  @visibleForTesting
  static void debugResetCache() {
    _cachedSupportDirectoryFuture = null;
    _cachedIndexItems = null;
    _cachedMergedItems = null;
    _cachedPathById = null;
    _cacheDirty = true;
    _cacheLoadingFuture = null;
  }

  static Future<String?> importFromGallery() async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) {
      return null;
    }
    return importFromFile(
      sourcePath: picked.path,
      preferredDisplayName: p.basenameWithoutExtension(picked.path),
      source: importedSource,
    );
  }

  /// 从文件路径导入自定义壁纸
  static Future<String> importFromFile({
    required String sourcePath,
    required String preferredDisplayName,
    required String source,
  }) async {
    final Directory filesDir = await _getFilesDirectory(create: true);
    final List<LaunchWallpaperItem> items = await _getIndexItems();
    final DateTime now = DateTime.now();

    final String id = _uuid.v4();
    final String extension = p.extension(sourcePath).toLowerCase();
    final String fileName = '$id$extension';
    final String destinationPath = p.join(filesDir.path, fileName);

    await File(sourcePath).copy(destinationPath);
    final LaunchWallpaperItem item = LaunchWallpaperItem(
      id: id,
      displayName: _normalizeDisplayName(
        preferredDisplayName,
        fallbackIndex: items.length + 1,
      ),
      fileName: fileName,
      assetPath: null,
      source: source,
      createdAt: now,
      updatedAt: now,
    );
    items.add(item);
    await _saveIndex(items);

    AppLogger.info(
      'Launch wallpaper imported to managed folder',
      loggerName: 'LaunchWallpaperFileService',
      context: <String, Object?>{
        'sourcePath': sourcePath,
        'destinationPath': destinationPath,
        'id': id,
      },
    );
    return id;
  }

  /// 列出所有需要渲染的壁纸项
  /// 
  /// 数据用于 UI 展示
  static Future<List<LaunchWallpaperItem>> listWallpapers({
    bool refreshFromDisk = false,
  }) async {
    await _ensureCache(refreshFromDisk: refreshFromDisk);
    return List<LaunchWallpaperItem>.from(_cachedMergedItems!);
  }

  static Future<Map<String, String>> listWallpaperPathById({
    bool refreshFromDisk = false,
  }) async {
    await _ensureCache(refreshFromDisk: refreshFromDisk);
    return Map<String, String>.from(_cachedPathById!);
  }

  static Future<LaunchWallpaperResolved?> resolveWallpaper(
    LaunchWallpaperRef ref,
  ) async {
    if (ref.id.isEmpty) {
      return null;
    }
    if (ref.type == LaunchWallpaperRef.typeNetwork) {
      return null;
    }
    final List<LaunchWallpaperItem> items = await listWallpapers();
    final LaunchWallpaperItem? item = _findItemById(
      items,
      wallpaperId: ref.id,
    );
    if (item == null) {
      return null;
    }
    if (ref.type == LaunchWallpaperRef.typeBuiltin) {
      final String? assetPath = item.assetPath;
      if (assetPath == null || assetPath.isEmpty) {
        return null;
      }
      return LaunchWallpaperResolved.asset(assetPath);
    }
    final String? fileName = item.fileName;
    if (fileName == null || fileName.isEmpty) {
      return null;
    }
    final File file = await _getFileByName(fileName);
    if (!await file.exists()) {
      return null;
    }
    return LaunchWallpaperResolved.file(file.path);
  }

  static Future<LaunchWallpaperResolved?> resolveWallpaperById(
    String wallpaperId,
  ) {
    return resolveWallpaper(
      LaunchWallpaperRef(
        type: LaunchWallpaperRef.typeLocal,
        id: wallpaperId,
      ),
    );
  }

  static Future<String?> resolveWallpaperPathById(String wallpaperId) async {
    final LaunchWallpaperResolved? resolved = await resolveWallpaperById(
      wallpaperId,
    );
    return resolved?.filePath;
  }

  static Future<String?> resolveWallpaperPathByFileName(String fileName) async {
    if (fileName.isEmpty) {
      return null;
    }
    final File file = await _getFileByName(fileName);
    if (!await file.exists()) {
      return null;
    }
    return file.path;
  }

  /// 重命名自定义壁纸项
  static Future<void> renameWallpaper({
    required String wallpaperId,
    required String displayName,
  }) async {
    if (_isBuiltinWallpaperId(wallpaperId)) {
      // 该情况不应该发生，即内置壁纸不允许修改名字
      AppLogger.warning(
        "Unexpect Exception: Failed to rename: Wallpaper $wallpaperId is builtin", 
        loggerName: 'LaunchWallpaperFileService',
      );
      return;
    }

    final String normalized =
        _normalizeDisplayName(displayName, fallbackIndex: 0);
    final List<LaunchWallpaperItem> items = await _getIndexItems();
    final int index = items.indexWhere((item) => item.id == wallpaperId);
    if (index < 0) {
      return;
    }
    items[index] = items[index].copyWith(
      displayName: normalized,
      updatedAt: DateTime.now(),
    );
    await _saveIndex(items);
  }

  static Future<void> deleteWallpaper(String wallpaperId) async {
    final List<LaunchWallpaperItem> items = await _getIndexItems();
    final int index = items.indexWhere((item) => item.id == wallpaperId);
    if (index < 0) {
      return;
    }
    final LaunchWallpaperItem removed = items.removeAt(index);
    await _saveIndex(items);

    final String? fileName = removed.fileName;
    if (fileName == null || fileName.isEmpty) {
      return;
    }
    final File file = await _getFileByName(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static LaunchWallpaperItem? _findItemById(
    List<LaunchWallpaperItem> items, {
    required String wallpaperId,
  }) {
    for (final LaunchWallpaperItem item in items) {
      if (item.id == wallpaperId) {
        return item;
      }
    }
    return null;
  }

  /// 从文件读取用户自定义壁纸项索引
  /// 
  /// 旧版本的壁纸项索引格式返回的列表中可能会包含内置壁纸项
  /// 所以这里需要过滤掉内置壁纸项
  static Future<List<LaunchWallpaperItem>> _readIndexItems() async {
    final File indexFile = await _getIndexFile(create: false);
    if (!await indexFile.exists()) {
      return <LaunchWallpaperItem>[];
    }
    final String raw = await indexFile.readAsString();
    if (raw.trim().isEmpty) {
      return <LaunchWallpaperItem>[];
    }
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) {
      return <LaunchWallpaperItem>[];
    }
    final List<LaunchWallpaperItem> items = <LaunchWallpaperItem>[];
    for (final Object? item in decoded) {
      if (item is! Map) {
        continue;
      }
      final LaunchWallpaperItem parsed = LaunchWallpaperItem.fromJson(
        Map<String, dynamic>.from(item),
      );
      if (parsed.source == builtinSource) {
        continue;
      }
      items.add(parsed);
    }
    return items;
  }

  /// 将内置壁纸项合并到用户自定义壁纸项中
  static List<LaunchWallpaperItem> _mergeBuiltinItems(
    List<LaunchWallpaperItem> items,
  ) {
    final List<LaunchWallpaperItem> merged = <LaunchWallpaperItem>[...items];
    final DateTime now = DateTime.now();
    for (final (String id, String name, String assetPath) in _builtinSeeds) {
      final int index = merged.indexWhere((item) => item.id == id);
      if (index < 0) {
        merged.add(
          LaunchWallpaperItem(
            id: id,
            displayName: name,
            fileName: null,
            assetPath: assetPath,
            source: builtinSource,
            createdAt: now,
            updatedAt: now,
          ),
        );
        continue;
      }
      final LaunchWallpaperItem current = merged[index];
      if (current.source != builtinSource) {
        merged[index] = current.copyWith(
          displayName: name,
          source: builtinSource,
          fileName: null,
          assetPath: assetPath,
        );
        continue;
      }
      if (current.assetPath != assetPath || current.displayName != name) {
        merged[index] = current.copyWith(
          displayName: name,
          assetPath: assetPath,
        );
      }
    }
    return merged;
  }

  static String _normalizeDisplayName(String value,
      {required int fallbackIndex}) {
    final String trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    if (fallbackIndex > 0) {
      return 'Wallpaper $fallbackIndex';
    }
    return 'Wallpaper';
  }

  static Future<Directory> _getBaseDirectory({required bool create}) async {
    final Directory supportDir = await _getSupportDirectory();
    final Directory base = Directory(p.join(supportDir.path, _folderName));
    if (create) {
      await base.create(recursive: true);
    }
    return base;
  }

  static Future<Directory> _getSupportDirectory() {
    return _cachedSupportDirectoryFuture ??= getApplicationSupportDirectory();
  }

  static Future<Directory> _getFilesDirectory({required bool create}) async {
    final Directory base = await _getBaseDirectory(create: create);
    final Directory filesDir = Directory(p.join(base.path, _filesFolderName));
    if (create) {
      await filesDir.create(recursive: true);
    }
    return filesDir;
  }

  static Future<File> _getIndexFile({required bool create}) async {
    final Directory base = await _getBaseDirectory(create: create);
    return File(p.join(base.path, _indexFileName));
  }

  static Future<File> _getFileByName(String fileName) async {
    final Directory filesDir = await _getFilesDirectory(create: false);
    return File(p.join(filesDir.path, fileName));
  }

  /// 保存用户自定义壁纸项索引
  static Future<void> _saveIndex(List<LaunchWallpaperItem> items) async {
    final List<LaunchWallpaperItem> sanitizedItems = items
        .where((item) => item.source != builtinSource)
        .toList(growable: false);
    final File indexFile = await _getIndexFile(create: true);
    final String raw = jsonEncode(
      sanitizedItems.map((item) => item.toJson()).toList(growable: false),
    );
    await indexFile.writeAsString(raw);
    await _updateCacheFromIndexItems(sanitizedItems);
    AppLogger.info(
      'Launch wallpaper index saved',
      loggerName: 'LaunchWallpaperFileService',
      context: <String, Object?>{
        'count': sanitizedItems.length,
      },
    );
  }

  static Future<List<LaunchWallpaperItem>> _getIndexItems() async {
    await _ensureCache(refreshFromDisk: false);
    return List<LaunchWallpaperItem>.from(_cachedIndexItems!);
  }

  static bool _isBuiltinWallpaperId(String wallpaperId) {
    for (final (String id, _, _) in _builtinSeeds) {
      if (id == wallpaperId) {
        return true;
      }
    }
    return false;
  }

  static Future<void> _ensureCache({required bool refreshFromDisk}) async {
    if (!refreshFromDisk &&
        !_cacheDirty &&
        _cachedIndexItems != null &&
        _cachedMergedItems != null &&
        _cachedPathById != null) {
      return;
    }
    final Future<void>? inFlight = _cacheLoadingFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final Future<void> loading = _reloadCacheFromDisk();
    _cacheLoadingFuture = loading;
    try {
      await loading;
    } finally {
      if (identical(_cacheLoadingFuture, loading)) {
        _cacheLoadingFuture = null;
      }
    }
  }

  static Future<void> _reloadCacheFromDisk() async {
    final List<LaunchWallpaperItem> indexItems = await _readIndexItems();
    await _updateCacheFromIndexItems(indexItems);
  }

  static Future<void> _updateCacheFromIndexItems(
    List<LaunchWallpaperItem> indexItems,
  ) async {
    _cachedIndexItems = List<LaunchWallpaperItem>.from(indexItems);
    _cachedMergedItems = _mergeBuiltinItems(
      List<LaunchWallpaperItem>.from(indexItems),
    );
    _cachedPathById = await _buildPathByIdFromItems(_cachedMergedItems!);
    _cacheDirty = false;
  }

  /// 解析id到路径的映射
  ///
  /// 返回的路径仅为用户的自定义壁纸路径，不包含内置壁纸路径
  ///
  /// 出现异常时，返回空映射
  static Future<Map<String, String>> _buildPathByIdFromItems(
    List<LaunchWallpaperItem> items,
  ) async {
    final Directory filesDir = await _getFilesDirectory(create: false);
    final Map<String, String> result = <String, String>{};
    for (final LaunchWallpaperItem item in items) {
      final String? fileName = item.fileName;
      if (fileName == null || fileName.isEmpty) {
        continue;
      }
      result[item.id] = p.join(filesDir.path, fileName);
    }
    return result;
  }
}
