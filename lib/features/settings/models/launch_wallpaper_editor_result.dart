import 'package:onetj/models/launch_wallpaper_ref.dart';

enum LaunchWallpaperEditorAction {
  unchanged,
  selected,
}

class LaunchWallpaperEditorResult {
  const LaunchWallpaperEditorResult._({
    required this.action,
    required this.wallpaperRef,
  });

  const LaunchWallpaperEditorResult.unchanged()
      : this._(
          action: LaunchWallpaperEditorAction.unchanged,
          wallpaperRef: LaunchWallpaperRef.defaultValue,
        );

  const LaunchWallpaperEditorResult.selected(LaunchWallpaperRef wallpaperRef)
      : this._(
          action: LaunchWallpaperEditorAction.selected,
          wallpaperRef: wallpaperRef,
        );

  final LaunchWallpaperEditorAction action;
  final LaunchWallpaperRef wallpaperRef;
}
