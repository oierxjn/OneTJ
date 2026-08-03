import 'package:flutter/material.dart';
import 'package:full_svg_flutter/full_svg_flutter.dart';

/// 功能网格首页的一级功能入口。
class FunctionGrid extends StatelessWidget {
  const FunctionGrid({
    required this.timetableLabel,
    required this.physicsLabLabel,
    required this.settingsLabel,
    required this.gradesLabel,
    required this.toolsLabel,
    required this.aboutLabel,
    required this.onTimetableTap,
    required this.onPhysicsLabTap,
    required this.onSettingsTap,
    required this.onGradesTap,
    required this.onToolsTap,
    required this.onAboutTap,
    super.key,
  });

  final String timetableLabel;
  final String physicsLabLabel;
  final String settingsLabel;
  final String gradesLabel;
  final String toolsLabel;
  final String aboutLabel;
  final VoidCallback onTimetableTap;
  final VoidCallback onPhysicsLabTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onGradesTap;
  final VoidCallback onToolsTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final List<_FunctionGridItem> items = <_FunctionGridItem>[
      _FunctionGridItem(
        label: timetableLabel,
        assetPath: 'assets/icons/fluentemoji/alarm_clock_color.svg',
        onTap: onTimetableTap,
      ),
      _FunctionGridItem(
        label: physicsLabLabel,
        assetPath: 'assets/icons/fluentemoji/memo_color.svg',
        onTap: onPhysicsLabTap,
      ),
      _FunctionGridItem(
        label: settingsLabel,
        assetPath: 'assets/icons/fluentemoji/gear_color.svg',
        onTap: onSettingsTap,
      ),
      _FunctionGridItem(
        label: gradesLabel,
        assetPath: 'assets/icons/fluentemoji/anguished_face_color.svg',
        onTap: onGradesTap,
      ),
      _FunctionGridItem(
        label: toolsLabel,
        assetPath: 'assets/icons/fluentemoji/desktop_computer_color.svg',
        onTap: onToolsTap,
      ),
      _FunctionGridItem(
        label: aboutLabel,
        assetPath: 'assets/icons/fluentemoji/teddy_bear_color.svg',
        onTap: onAboutTap,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useThreeColumns = constraints.maxWidth >= 720;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: useThreeColumns ? 3 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: useThreeColumns ? 1.2 : 1.1,
          ),
          itemBuilder: (context, index) =>
              _FunctionGridCard(item: items[index]),
        );
      },
    );
  }
}

class _FunctionGridItem {
  const _FunctionGridItem({
    required this.label,
    required this.assetPath,
    required this.onTap,
  });

  final String label;
  final String assetPath;
  final VoidCallback onTap;
}

class _FunctionGridCard extends StatelessWidget {
  const _FunctionGridCard({required this.item});

  final _FunctionGridItem item;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: item.label,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: colors.surfaceContainerHighest,
        child: InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => FSvgPicture.asset(
                      item.assetPath,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
