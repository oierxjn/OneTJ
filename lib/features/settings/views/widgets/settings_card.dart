import 'package:flutter/material.dart';

import 'package:onetj/features/settings/views/widgets/settings_card_visual_state.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.status = SettingsCardStatus.normal,
    this.margin,
    this.clipBehavior,
    this.elevation,
    super.key,
  });

  final SettingsCardStatus status;
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Clip? clipBehavior;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final SettingsCardVisualState visual =
        SettingsCardVisualState.fromStatus(context, status);
    final Widget content = 
        ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
        );
    return Card(
      color: visual.color,
      shape: visual.shape,
      margin: margin,
      clipBehavior: clipBehavior,
      elevation: elevation,
      child: content,
    );
  }
}
