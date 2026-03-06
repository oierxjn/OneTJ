import 'package:flutter/material.dart';

enum SettingsCardStatus {
  normal,
  dirty,
  error,
}

class SettingsCardVisualState {
  const SettingsCardVisualState({
    this.color,
    this.shape,
  });

  final Color? color;
  final ShapeBorder? shape;

  static SettingsCardVisualState fromStatus(
    BuildContext context,
    SettingsCardStatus status,
  ) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    switch (status) {
      case SettingsCardStatus.normal:
        return const SettingsCardVisualState();
      case SettingsCardStatus.dirty:
        return SettingsCardVisualState(
          color: colors.secondaryContainer
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
