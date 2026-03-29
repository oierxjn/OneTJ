import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class PhysicsLabFormula extends StatelessWidget {
  const PhysicsLabFormula.inline({
    super.key,
    required this.tex,
    this.color,
    this.fontSize,
  }) : selectable = false;

  const PhysicsLabFormula.block({
    super.key,
    required this.tex,
    this.color,
    this.fontSize,
  }) : selectable = false;

  final String tex;
  final Color? color;
  final double? fontSize;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = Theme.of(context).textTheme.bodyMedium ??
        const TextStyle();
    final TextStyle textStyle = baseStyle.copyWith(
      color: color,
      fontSize: fontSize,
    );
    return Math.tex(
      tex,
      textStyle: textStyle,
    );
  }
}
