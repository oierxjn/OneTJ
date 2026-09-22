import 'package:flutter/material.dart';

/// 设置卡片的即时状态，四者并列互斥，每张卡片同一时刻只呈现其一。
///
/// 多个底层条件同时为真时由上层按 error > saving > success 消解成单值。
enum SettingsCardStatus {
  normal,
  saving,
  success,
  error,
}

class SettingsCardVisualState {
  const SettingsCardVisualState({
    this.color,
    this.shape,
  });

  final Color? color;
  final ShapeBorder? shape;

  /// 成功态的柔和绿，M3 ColorScheme 没有语义化的 success 色，按亮度给两档。
  static const Color _successLight = Color(0xFFDFF2E3);
  static const Color _successDark = Color(0xFF1E3626);

  /// 状态色切换的过渡时长。
  static const Duration statusTransitionDuration = Duration(milliseconds: 200);

  /// M3 下 Card 的默认底色，状态无覆盖色时回落到它以保持原外观。
  static Color baseCardColor(BuildContext context) {
    return Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surfaceContainerLow;
  }

  static SettingsCardVisualState fromStatus(
    BuildContext context,
    SettingsCardStatus status,
  ) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    switch (status) {
      case SettingsCardStatus.normal:
        return const SettingsCardVisualState();
      case SettingsCardStatus.saving:
        return SettingsCardVisualState(color: colors.primaryContainer);
      case SettingsCardStatus.success:
        return SettingsCardVisualState(
          color: Theme.of(context).brightness == Brightness.light
              ? _successLight
              : _successDark,
        );
      case SettingsCardStatus.error:
        return SettingsCardVisualState(
          color: colors.errorContainer,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colors.error, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
        );
    }
  }
}
