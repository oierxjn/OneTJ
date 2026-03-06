import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:onetj/models/dashboard_upcoming_mode.dart';

class UpcomingCoursesCard extends StatefulWidget {
  const UpcomingCoursesCard({
    required this.l10n,
    required this.mode,
    required this.countController,
    required this.enabled,
    required this.summaryText,
    required this.onModeChanged,
    required this.onCountChanged,
    this.cardColor,
    this.cardShape,
    super.key,
  });

  final AppLocalizations l10n;
  final DashboardUpcomingMode mode;
  final TextEditingController countController;
  final bool enabled;
  final String summaryText;
  final ValueChanged<DashboardUpcomingMode> onModeChanged;
  final ValueChanged<String> onCountChanged;
  final Color? cardColor;
  final ShapeBorder? cardShape;

  @override
  State<UpcomingCoursesCard> createState() => _UpcomingCoursesCardState();
}

class _UpcomingCoursesCardState extends State<UpcomingCoursesCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
    if (_expanded) {
      _expandController.forward();
      return;
    }
    _expandController.reverse();
  }

  void _onModeChanged(DashboardUpcomingMode? value) {
    if (value == null) {
      return;
    }
    widget.onModeChanged(value);
  }

  Widget _buildModeOption({
    required DashboardUpcomingMode value,
    required String title,
  }) {
    return RadioListTile<DashboardUpcomingMode>(
      contentPadding: EdgeInsets.zero,
      value: value,
      groupValue: widget.mode,
      onChanged: widget.enabled ? _onModeChanged : null,
      title: Text(title),
    );
  }

  Widget _buildCountField() {
    return TextField(
      controller: widget.countController,
      onChanged: widget.onCountChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      enabled: widget.enabled,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        labelText: widget.l10n.settingsDashboardUpcomingCountLabel,
        helperText: widget.l10n.settingsDashboardUpcomingCountHint,
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildModeOption(
            value: DashboardUpcomingMode.thisWeek,
            title: widget.l10n.settingsDashboardUpcomingModeThisWeek,
          ),
          _buildModeOption(
            value: DashboardUpcomingMode.today,
            title: widget.l10n.settingsDashboardUpcomingModeToday,
          ),
          _buildModeOption(
            value: DashboardUpcomingMode.count,
            title: widget.l10n.settingsDashboardUpcomingModeCount,
          ),
          _CountFieldSection(
            visible: widget.mode == DashboardUpcomingMode.count,
            child: _buildCountField(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.cardColor,
      shape: widget.cardShape,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(widget.l10n.settingsDashboardUpcomingTitle),
            subtitle: Text(widget.summaryText),
            trailing: AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              child: const Icon(Icons.expand_more),
            ),
            onTap: _toggleExpanded,
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: _buildExpandedContent(),
          ),
        ],
      ),
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
