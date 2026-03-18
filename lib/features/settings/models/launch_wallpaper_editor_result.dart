enum LaunchWallpaperEditorAction {
  unchanged,
  selectedCustom,
  resetToDefault,
}

class LaunchWallpaperEditorResult {
  const LaunchWallpaperEditorResult._({
    required this.action,
    this.wallpaperId,
  });

  const LaunchWallpaperEditorResult.unchanged()
      : this._(action: LaunchWallpaperEditorAction.unchanged);

  const LaunchWallpaperEditorResult.selectedCustom(String wallpaperId)
      : this._(
          action: LaunchWallpaperEditorAction.selectedCustom,
          wallpaperId: wallpaperId,
        );

  const LaunchWallpaperEditorResult.resetToDefault()
      : this._(action: LaunchWallpaperEditorAction.resetToDefault);

  final LaunchWallpaperEditorAction action;
  final String? wallpaperId;
}
