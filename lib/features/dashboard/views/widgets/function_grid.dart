import 'package:flutter/material.dart';

/// 功能网格首页的一级功能入口。
class FunctionGrid extends StatelessWidget {
  const FunctionGrid({
    required this.timetableLabel,
    required this.physicsLabLabel,
    required this.settingsLabel,
    required this.gradesLabel,
    required this.cetScoreLabel,
    required this.studentExamsLabel,
    required this.toolsLabel,
    required this.aboutLabel,
    required this.onTimetableTap,
    required this.onPhysicsLabTap,
    required this.onSettingsTap,
    required this.onGradesTap,
    required this.onCetScoreTap,
    required this.onStudentExamsTap,
    required this.onToolsTap,
    required this.onAboutTap,
    super.key,
  });

  final String timetableLabel;
  final String physicsLabLabel;
  final String settingsLabel;
  final String gradesLabel;
  final String cetScoreLabel;
  final String studentExamsLabel;
  final String toolsLabel;
  final String aboutLabel;
  final VoidCallback onTimetableTap;
  final VoidCallback onPhysicsLabTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onGradesTap;
  final VoidCallback onCetScoreTap;
  final VoidCallback onStudentExamsTap;
  final VoidCallback onToolsTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final List<_FunctionGridItem> items = <_FunctionGridItem>[
      _FunctionGridItem(
        label: timetableLabel,
        assetPath: 'assets/icons/function_grid/alarm_clock_3d.png',
        onTap: onTimetableTap,
      ),
      _FunctionGridItem(
        label: physicsLabLabel,
        assetPath: 'assets/icons/function_grid/memo_3d.png',
        onTap: onPhysicsLabTap,
      ),
      _FunctionGridItem(
        label: settingsLabel,
        assetPath: 'assets/icons/function_grid/gear_3d.png',
        onTap: onSettingsTap,
      ),
      _FunctionGridItem(
        label: gradesLabel,
        assetPath: 'assets/icons/function_grid/anguished_face_3d.png',
        onTap: onGradesTap,
      ),
      _FunctionGridItem(
        label: cetScoreLabel,
        assetPath: 'assets/icons/function_grid/input_latin_letters_3d.png',
        onTap: onCetScoreTap,
      ),
      _FunctionGridItem(
        label: studentExamsLabel,
        assetPath: 'assets/icons/function_grid/spiral_calendar_3d.png',
        onTap: onStudentExamsTap,
      ),
      _FunctionGridItem(
        label: toolsLabel,
        assetPath: 'assets/icons/function_grid/desktop_computer_3d.png',
        onTap: onToolsTap,
      ),
      _FunctionGridItem(
        label: aboutLabel,
        assetPath: 'assets/icons/function_grid/teddy_bear_3d.png',
        onTap: onAboutTap,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useCompactLayout = constraints.maxWidth < 720;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: useCompactLayout ? 8 : 12,
            crossAxisSpacing: useCompactLayout ? 8 : 12,
            mainAxisExtent: useCompactLayout ? 88 : null,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) => _FunctionGridCard(
            item: items[index],
            compact: useCompactLayout,
          ),
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
  const _FunctionGridCard({required this.item, required this.compact});

  final _FunctionGridItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 16,
        vertical: compact ? 6 : 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (compact)
            SizedBox(
              width: 36,
              height: 36,
              child: Image.asset(
                item.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            )
          else
            Expanded(
              child: Image.asset(
                item.assetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
              ),
            ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            item.label,
            maxLines: compact ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            textAlign: compact ? TextAlign.center : null,
            style: compact
                ? Theme.of(context).textTheme.bodySmall
                : Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );

    final Widget tappable = compact
        ? Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: item.onTap, child: content),
          )
        : Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            color: colors.surfaceContainerHighest,
            child: InkWell(onTap: item.onTap, child: content),
          );

    return Semantics(button: true, label: item.label, child: tappable);
  }
}
