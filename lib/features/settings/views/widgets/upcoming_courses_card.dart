import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onetj/l10n/app_localizations.dart';

import 'package:onetj/features/settings/views/widgets/expandable_radio_card.dart';
import 'package:onetj/features/settings/views/widgets/settings_card_visual_state.dart';
import 'package:onetj/models/dashboard_upcoming_mode.dart';

/// 即将到来的课程选择卡片
class UpcomingCoursesCard extends StatelessWidget {
  const UpcomingCoursesCard({
    required this.l10n,
    required this.mode,
    required this.countController,
    required this.enabled,
    required this.summaryText,
    required this.onModeChanged,
    required this.onCountChanged,
    this.status = SettingsCardStatus.normal,
    super.key,
  });

  final AppLocalizations l10n;
  final DashboardUpcomingMode mode;
  final TextEditingController countController;
  final bool enabled;
  final String summaryText;
  final ValueChanged<DashboardUpcomingMode> onModeChanged;
  final ValueChanged<String> onCountChanged;
  final SettingsCardStatus status;

  List<RadioOption<DashboardUpcomingMode>> _buildOptions() {
    return [
      RadioOption(
        value: DashboardUpcomingMode.thisWeek,
        title: l10n.settingsDashboardUpcomingModeThisWeek,
      ),
      RadioOption(
        value: DashboardUpcomingMode.today,
        title: l10n.settingsDashboardUpcomingModeToday,
      ),
      RadioOption(
        value: DashboardUpcomingMode.count,
        title: l10n.settingsDashboardUpcomingModeCount,
      ),
    ];
  }

  Widget _buildCountField() {
    return _CountFieldSection(
      visible: mode == DashboardUpcomingMode.count,
      child: TextField(
        controller: countController,
        onChanged: onCountChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        enabled: enabled,
        decoration: InputDecoration(
          isDense: true,
          border: const OutlineInputBorder(),
          labelText: l10n.settingsDashboardUpcomingCountLabel,
          helperText: l10n.settingsDashboardUpcomingCountHint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableRadioCard<DashboardUpcomingMode>(
      title: l10n.settingsDashboardUpcomingTitle,
      summaryText: summaryText,
      value: mode,
      options: _buildOptions(),
      onChanged: onModeChanged,
      enabled: enabled,
      status: status,
      extraContent: _buildCountField(),
    );
  }
}

class _CountFieldSection extends StatefulWidget {
  const _CountFieldSection({
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  State<_CountFieldSection> createState() => _CountFieldSectionState();
}

class _CountFieldSectionState extends State<_CountFieldSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget.visible ? 1 : 0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void didUpdateWidget(covariant _CountFieldSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) {
      return;
    }
    if (widget.visible) {
      _controller.forward();
      return;
    }
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.visible,
      child: SizeTransition(
        sizeFactor: _animation,
        axisAlignment: -1.0,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: widget.child,
        ),
      ),
    );
  }
}
