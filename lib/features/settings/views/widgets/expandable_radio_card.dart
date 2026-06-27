import 'package:flutter/material.dart';

import 'package:onetj/features/settings/views/widgets/settings_card_visual_state.dart';

/// 一个可展开的选项行
class RadioOption<T> {
  const RadioOption({
    required this.value,
    required this.title,
    this.icon,
  });

  final T value;
  final String title;
  final IconData? icon;
}

/// 可展开的单选卡片
///
/// 点击 [ListTile] 头部后展开，以 [RadioListTile] 展示选项列表。
/// 泛型 [T] 为枚举类型，如 [ThemeMode] 或 [DashboardUpcomingMode]。
///
/// [extraContent] 为展开后的附加内容（如 Upcoming 的 count 输入框），
/// 传 `null` 表示不显示。
class ExpandableRadioCard<T> extends StatefulWidget {
  const ExpandableRadioCard({
    required this.title,
    required this.summaryText,
    required this.value,
    required this.options,
    required this.onChanged,
    this.leadingIcon,
    this.enabled = true,
    this.status = SettingsCardStatus.normal,
    this.extraContent,
    super.key,
  });

  final String title;
  final String summaryText;
  final IconData? leadingIcon;
  final T value;
  final List<RadioOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final SettingsCardStatus status;
  final Widget? extraContent;

  @override
  State<ExpandableRadioCard<T>> createState() => _ExpandableRadioCardState<T>();
}

class _ExpandableRadioCardState<T> extends State<ExpandableRadioCard<T>>
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

  void _onChanged(T? value) {
    if (value == null) {
      return;
    }
    widget.onChanged(value);
  }

  Widget _buildOption(RadioOption<T> option) {
    return RadioListTile<T>(
      contentPadding: EdgeInsets.zero,
      value: option.value,
      groupValue: widget.value,
      onChanged: widget.enabled ? _onChanged : null,
      title: Row(
        children: [
          if (option.icon != null) ...[
            Icon(option.icon, size: 20),
            const SizedBox(width: 12),
          ],
          Text(option.title),
        ],
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
          ...widget.options.map(_buildOption),
          if (widget.extraContent != null) ...[
            const SizedBox(height: 8),
            widget.extraContent!,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsCardVisualState visual =
        SettingsCardVisualState.fromStatus(context, widget.status);
    return Card(
      color: visual.color,
      shape: visual.shape,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading:
                widget.leadingIcon != null ? Icon(widget.leadingIcon) : null,
            title: Text(widget.title),
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
