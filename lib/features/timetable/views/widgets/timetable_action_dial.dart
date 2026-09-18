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
/// 收起时是一个与时间列同宽的圆形触发器；点击后经 [OverlayPortal]
/// 向下展开动作面板，点击面板外任意处或任一动作后收起。
/// 锚定位置由调用方通过外部 [CompositedTransformTarget] 与
/// [width] 共同决定。
class TimetableActionDial extends StatefulWidget {
  const TimetableActionDial({
    required this.width,
    required this.actions,
    super.key,
  });

  final double width;
  final List<TimetableDialAction> actions;

  @override
  State<TimetableActionDial> createState() => _TimetableActionDialState();
}

class _TimetableActionDialState extends State<TimetableActionDial> {
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _portalController = OverlayPortalController();

  bool get _isOpen => _portalController.isShowing;

  void _toggle() {
    if (_isOpen) {
      _portalController.hide();
    } else {
      _portalController.show();
    }
  }

  void _close() {
    if (_isOpen) {
      _portalController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: _buildOverlay,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SizedBox(
          width: widget.width,
          height: 40,
          child: Material(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _toggle,
              child: AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: _animationDuration(context),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: const SizedBox.shrink(),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
            color: colors.surfaceContainerLow,
            child: TweenAnimationBuilder<double>(
              duration: _animationDuration(context),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) => Transform.scale(
                scale: 0.92 + 0.08 * value,
                alignment: Alignment.topLeft,
                child: Opacity(opacity: value, child: child),
              ),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final TimetableDialAction action in widget.actions)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          _close();
                          action.onTap();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                action.icon,
                                size: 18,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                action.label,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Duration _animationDuration(BuildContext context) {
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 150);
  }
}
