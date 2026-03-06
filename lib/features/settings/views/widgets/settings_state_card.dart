import 'package:flutter/material.dart';

import 'package:onetj/features/settings/views/widgets/settings_card_visual_state.dart';

class SettingsStateCard extends StatelessWidget {
  const SettingsStateCard({
    required this.status,
    required this.child,
    this.margin,
    this.clipBehavior,
    this.elevation,
    super.key,
  });

  final SettingsCardStatus status;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final Clip? clipBehavior;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final SettingsCardVisualState visual =
        SettingsCardVisualState.fromStatus(context, status);
    return Card(
      color: visual.color,
      shape: visual.shape,
      margin: margin,
      clipBehavior: clipBehavior,
      elevation: elevation,
      child: child,
    );
  }
}
