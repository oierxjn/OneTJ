import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/features/settings/views/widgets/expandable_radio_card.dart';
import 'package:onetj/models/theme_preferences.dart';

/// 主页导航布局选择卡片。
class HomeLayoutCard extends StatelessWidget {
  const HomeLayoutCard({
    required this.l10n,
    required this.layout,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final AppLocalizations l10n;
  final HomeLayout layout;
  final bool enabled;
  final ValueChanged<HomeLayout> onChanged;

  String _summaryText() {
    switch (layout) {
      case HomeLayout.bottomNavigation:
        return l10n.settingsAppearanceHomeLayoutBottomNavigation;
      case HomeLayout.functionGrid:
        return l10n.settingsAppearanceHomeLayoutFunctionGrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableRadioCard<HomeLayout>(
      leadingIcon: Icons.dashboard_customize_outlined,
      title: l10n.settingsAppearanceHomeLayoutTitle,
      summaryText: _summaryText(),
      value: layout,
      options: [
        RadioOption(
          value: HomeLayout.bottomNavigation,
          title: l10n.settingsAppearanceHomeLayoutBottomNavigation,
          icon: Icons.navigation_outlined,
        ),
        RadioOption(
          value: HomeLayout.functionGrid,
          title: l10n.settingsAppearanceHomeLayoutFunctionGrid,
          icon: Icons.grid_view_outlined,
        ),
      ],
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}
