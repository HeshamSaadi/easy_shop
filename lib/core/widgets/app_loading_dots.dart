import 'package:easy_shop/core/theme/app_sizes.dart';
import 'package:easy_shop/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Three dots that fade in and out one after the other.
class AppLoadingDots extends StatefulWidget {
  const AppLoadingDots({required this.color, super.key});

  final Color color;

  @override
  State<AppLoadingDots> createState() => _AppLoadingDotsState();
}

class _AppLoadingDotsState extends State<AppLoadingDots>
    with SingleTickerProviderStateMixin {
  static const int _dotCount = 3;
  static const Duration _cycle = Duration(milliseconds: 1200);
  static const double _minOpacity = 0.3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Each dot starts a bit later than the one before it.
  // The value goes 0 -> 1 -> 0 over one cycle (a triangle wave).
  double _opacityFor(int index) {
    final phase = (_controller.value - index / _dotCount) % 1.0;
    final pulse = 1 - (phase * 2 - 1).abs();
    return _minOpacity + (1 - _minOpacity) * pulse;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _dotCount; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Opacity(
                opacity: _opacityFor(i),
                child: Container(
                  width: AppSizes.loadingDot,
                  height: AppSizes.loadingDot,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
