import 'package:flutter/material.dart';

/// A smooth animated progress bar that transitions its width when [value] changes.
/// [value] must be between 0.0 and 1.0.
class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Gradient? foregroundGradient;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Duration duration;
  final Curve curve;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.foregroundGradient,
    this.foregroundColor,
    this.borderRadius,
    this.boxShadow,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(height / 2);
    final clampedValue = value.clamp(0.0, 1.0);

    return Stack(
      children: [
        // Background track
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.1),
            borderRadius: radius,
          ),
        ),
        // Animated fill
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: clampedValue),
          duration: duration,
          curve: curve,
          builder: (context, animatedValue, _) {
            if (animatedValue <= 0) return const SizedBox.shrink();
            return FractionallySizedBox(
              widthFactor: animatedValue,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: foregroundGradient,
                  color: foregroundGradient == null
                      ? (foregroundColor ?? Colors.cyan)
                      : null,
                  borderRadius: radius,
                  boxShadow: boxShadow,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
