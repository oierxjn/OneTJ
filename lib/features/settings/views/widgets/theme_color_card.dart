import 'package:flutter/material.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/features/settings/views/widgets/expandable_radio_card.dart';

/// 主题色选择卡片
class ThemeColorCard extends StatelessWidget {
  const ThemeColorCard({
    required this.l10n,
    required this.color,
    required this.enabled,
    required this.onColorChanged,
    super.key,
  });

  final AppLocalizations l10n;
  final ThemeMode color;
  final bool enabled;
  final ValueChanged<ThemeMode> onColorChanged;

  String _summaryText() {
    switch (color) {
      case ThemeMode.system:
        return l10n.settingsAppearanceThemeColorSystem;
      case ThemeMode.light:
        return l10n.settingsAppearanceThemeColorLight;
      case ThemeMode.dark:
        return l10n.settingsAppearanceThemeColorDark;
    }
  }

  List<RadioOption<ThemeMode>> _buildOptions() {
    return [
      RadioOption(
        value: ThemeMode.system,
        title: l10n.settingsAppearanceThemeColorSystem,
        icon: Icons.brightness_auto,
      ),
      RadioOption(
        value: ThemeMode.light,
        title: l10n.settingsAppearanceThemeColorLight,
        icon: Icons.light_mode,
      ),
      RadioOption(
        value: ThemeMode.dark,
        title: l10n.settingsAppearanceThemeColorDark,
        icon: Icons.dark_mode,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableRadioCard<ThemeMode>(
      leadingIcon: Icons.palette_outlined,
      title: l10n.settingsAppearanceThemeColorTitle,
      summaryText: _summaryText(),
      value: color,
      options: _buildOptions(),
      onChanged: onColorChanged,
      enabled: enabled,
    );
  }
}
