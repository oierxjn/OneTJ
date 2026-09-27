import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:onetj/features/launcher/view_models/launcher_view_model.dart';
import 'package:onetj/models/settings_defaults.dart';

class LauncherView extends StatefulWidget {
  const LauncherView({super.key, required this.viewModel});

  final LauncherViewModel viewModel;

  @override
  State<LauncherView> createState() => _LauncherViewState();
}

class _LauncherViewState extends State<LauncherView> {
  static Future<void>? _initFuture;
  late final LauncherViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    // 引导结果通过 SessionController 发布，跳转由路由守卫完成，此处无需订阅事件。
    _initFuture ??= _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) => SizedBox.expand(
          child: _buildWallpaper(),
        ),
      ),
    );
  }

  Widget _buildWallpaper() {
    final String? assetPath = _viewModel.wallpaperAssetPath;
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultWallpaper(),
      );
    }
    final String? customPath = _viewModel.wallpaperFilePath;
    if (customPath != null) {
      return Image.file(
        File(customPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultWallpaper(),
      );
    }
    return _defaultWallpaper();
  }

  Widget _defaultWallpaper() {
    return Image.asset(
      kDefaultLaunchWallpaperAsset,
      fit: BoxFit.cover,
    );
  }
}
