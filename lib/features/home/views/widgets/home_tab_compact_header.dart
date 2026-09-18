import 'package:flutter/material.dart';

/// 一级页面在紧凑高度下隐藏 AppBar 后，内容顶部的按钮行。
///
/// 承接原 AppBar 中的返回入口与操作按钮；没有任何子项时退化为
/// 状态栏高度的占位，仍保证内容不顶进状态栏。
class HomeTabCompactHeader extends StatelessWidget {
  const HomeTabCompactHeader({
    super.key,
    this.leading,
    this.actions = const <Widget>[],
  });

  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (leading == null && actions.isEmpty) {
      return const SafeArea(
        top: true,
        bottom: false,
        child: SizedBox.shrink(),
      );
    }
    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Row(
          children: <Widget>[
            if (leading != null) leading!,
            const Spacer(),
            ...actions,
          ],
        ),
      ),
    );
  }
}
