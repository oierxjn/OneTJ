import 'package:flutter/material.dart';

/// 一级页面顶部的纤细导航行。
///
/// 仅在有内容时占位：网格布局下承载返回入口与页面标题，
/// 设置页在有未保存改动时承载保存按钮；否则整体不占空间。
/// 状态栏避让由页面自身的 SafeArea 负责，这里不做处理。
class HomeSlimHeader extends StatelessWidget {
  const HomeSlimHeader({
    super.key,
    this.leading,
    this.title,
    this.actions = const <Widget>[],
  });

  final Widget? leading;
  final String? title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (leading == null && title == null && actions.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: <Widget>[
          if (leading != null) leading!,
          if (title != null) ...<Widget>[
            const SizedBox(width: 4),
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
          ],
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
