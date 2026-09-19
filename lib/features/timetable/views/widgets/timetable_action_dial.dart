import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// 拨盘中的一个动作项。
class TimetableDialAction {
  const TimetableDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// 课程表视图切换行左端的动作拨盘。
///
/// 收起时是与时间列对齐的小型浮动按钮（FAB）；点击后经 [OverlayPortal]
/// 向下展开一列同为浮动按钮的动作项，鼠标悬停动作项时在其右侧显示
/// 文字标签，点击面板外任意处或任一动作后收起。
class TimetableActionDial extends StatefulWidget {
  const TimetableActionDial({
    required this.width,
    required this.actions,
    this.busy = false,
    super.key,
  });

  final double width;
  final List<TimetableDialAction> actions;

  /// 触发器是否处于忙碌状态（如课表刷新中）。
  ///
  /// 忙碌时触发器图标替换为转圈指示器，其余行为不变。
  final bool busy;

  @override
  State<TimetableActionDial> createState() => _TimetableActionDialState();
}

class _TimetableActionDialState extends State<TimetableActionDial> {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();
  final GlobalKey _triggerKey = GlobalKey();

  bool get _isOpen => _portalController.isShowing;

  /// 触发器在屏幕上的矩形，供面板屏障挖洞用；未挂载时为 null。
  Rect? get _triggerGlobalRect {
    final BuildContext? context = _triggerKey.currentContext;
    final RenderBox? box = context?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) {
      return null;
    }
    return box.localToGlobal(Offset.zero) & box.size;
  }

  // show/hide 只更新浮层条目，不会触发触发器所在子树重建；
  // chevron 的旋转角度依赖 _isOpen，必须显式 setState 才会动画。
  void _toggle() {
    setState(() {
      if (_isOpen) {
        _portalController.hide();
      } else {
        _portalController.show();
      }
    });
  }

  void _close() {
    if (!_isOpen) {
      return;
    }
    setState(_portalController.hide);
  }

  Duration _animationDuration(BuildContext context) {
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 150);
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: _buildOverlay,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox(
          // FloatingActionButton.small 内部以紧约束锁 40×40，但紧约束
          // 会被父级约束钳制：时间列宽度的响应式下限是 35，若框宽随之
          // 缩小，触发器会被压成 35×40 的胶囊，与 overlay 中不受挤压的
          // 动作按钮大小不一致。这里保证触发器框至少 40 宽。
          width: widget.width < 40 ? 40 : widget.width,
          height: 40,
          child: Center(
            child: FloatingActionButton.small(
              key: _triggerKey,
              onPressed: _toggle,
              // shrinkWrap 去掉 padded 触摸目标在布局上多出的 8px
              //（四周各 4px），保证触发器与动作项的可视尺寸、间隙一致。
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: widget.busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: _animationDuration(context),
                      child: const Icon(Icons.expand_more, size: 20),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          // 全屏收起屏障。opaque 会阻断命中测试，把触发器的悬停反馈
          // 一并挡掉，所以在触发器矩形处挖一个洞（命中测试尊重裁剪
          // 路径），洞内由触发器 FAB 自己响应悬停与点击。
          // ClipPath 在 BackdropFilter 外层，模糊与命中都被同一裁剪
          // 约束：洞外磨砂虚化背景，洞内与面板保持清晰，反衬拨盘。
          child: ClipPath(
            clipper: _TriggerHoleClipper(hole: _triggerGlobalRect),
            child: TweenAnimationBuilder<double>(
              duration: _animationDuration(context),
              tween: Tween<double>(begin: 0, end: _barrierBlurSigma),
              builder: (context, sigma, child) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: child,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          // 动作列与触发器做中心对齐：触发器在时间列宽度框内居中，
          // 若按左缘对齐，动作按钮会整体左偏，观感上像大小/位置不一致。
          // 偏移量与动作项之间的 spacing 相同，保证触发器与首个动作、
          // 动作项彼此之间的间隔一致。
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: const Offset(0, 8),
          child: Material(
            type: MaterialType.transparency,
            child: TweenAnimationBuilder<double>(
              duration: _animationDuration(context),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) => Transform.scale(
                scale: 0.92 + 0.08 * value,
                alignment: Alignment.topCenter,
                child: Opacity(opacity: value, child: child),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: <Widget>[
                  for (final TimetableDialAction action in widget.actions)
                    _DialActionItem(action: action, onClose: _close),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 收起屏障的背景模糊强度（sigma）。虚化洞外背景以反衬拨盘。
const double _barrierBlurSigma = 3.0;

/// 全屏收起屏障的裁剪：整屏矩形挖去 [hole]（触发器矩形）。
///
/// [hole] 为 null（触发器未挂载）时退化为不挖洞的整屏屏障。
class _TriggerHoleClipper extends CustomClipper<Path> {
  const _TriggerHoleClipper({required this.hole});

  final Rect? hole;

  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    final Rect? holeRect = hole;
    if (holeRect != null) {
      path.addRect(holeRect);
    }
    return path;
  }

  @override
  bool shouldReclip(_TriggerHoleClipper oldClipper) => oldClipper.hole != hole;
}

class _DialActionItem extends StatelessWidget {
  const _DialActionItem({required this.action, required this.onClose});

  final TimetableDialAction action;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      onClose();
      action.onTap();
    }

    return Semantics(
      label: action.label,
      button: true,
      child: _MouseHoverLabel(
        message: action.label,
        child: FloatingActionButton.small(
          heroTag: Object(),
          onPressed: handleTap,
          // 同触发器：shrinkWrap 去掉 padded 布局余量。
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Icon(action.icon, size: 20),
        ),
      ),
    );
  }
}

/// 鼠标悬停在子组件上时，在其右侧显示文字标签（桌面端提示）。
///
/// 不使用 Flutter 自带的 [Tooltip]，因为它的提示只能出现在
/// 目标上方或下方，无法水平偏移到右侧。
class _MouseHoverLabel extends StatefulWidget {
  const _MouseHoverLabel({required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  State<_MouseHoverLabel> createState() => _MouseHoverLabelState();
}

class _MouseHoverLabelState extends State<_MouseHoverLabel> {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    // overlay 条目会传入强制全屏的紧约束，必须用 Stack 松开，
    // 否则标签 Material 会撑满整个屏幕（只随图层偏移平移）。
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) => Stack(
        children: <Widget>[
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.centerRight,
            followerAnchor: Alignment.centerLeft,
            offset: const Offset(8, 0),
            child: Material(
              color: colors.inverseSurface,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  widget.message,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: colors.onInverseSurface),
                ),
              ),
            ),
          ),
        ],
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) => _controller.show(),
          onExit: (_) => _controller.hide(),
          child: widget.child,
        ),
      ),
    );
  }
}
