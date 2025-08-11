import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Focus and exposure adjustment widget
class FocusExposureWidget extends StatefulWidget {
  final Offset? focusPoint;
  final double exposureValue;
  final bool isVisible;
  final Function(double)? onExposureChanged;
  final VoidCallback? onDismiss;

  const FocusExposureWidget({
    super.key,
    this.focusPoint,
    this.exposureValue = 0.0,
    this.isVisible = false,
    this.onExposureChanged,
    this.onDismiss,
  });

  @override
  State<FocusExposureWidget> createState() => _FocusExposureWidgetState();
}

class _FocusExposureWidgetState extends State<FocusExposureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FocusExposureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
        // Auto-dismiss after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            widget.onDismiss?.call();
          }
        });
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.focusPoint == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Focus indicator
        Positioned(
          left: widget.focusPoint!.dx - 25,
          top: widget.focusPoint!.dy - 25,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        width: 2,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                    child: CustomPaint(
                      painter: FocusIndicatorPainter(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Exposure slider
        Positioned(
          left: widget.focusPoint!.dx + 40,
          top: widget.focusPoint!.dy - 60,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildExposureSlider(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExposureSlider() {
    return Container(
      height: 120,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Plus icon
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 4.w,
            ),
          ),

          // Slider
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: widget.exposureValue,
                min: -2.0,
                max: 2.0,
                divisions: 40,
                activeColor: AppTheme.lightTheme.colorScheme.tertiary,
                inactiveColor: Colors.white.withValues(alpha: 0.3),
                thumbColor: AppTheme.lightTheme.colorScheme.tertiary,
                onChanged: widget.onExposureChanged,
              ),
            ),
          ),

          // Minus icon
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconWidget(
              iconName: 'remove',
              color: Colors.white,
              size: 4.w,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for focus indicator
class FocusIndicatorPainter extends CustomPainter {
  final Color color;

  FocusIndicatorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final cornerLength = size.width * 0.2;

    // Draw corner brackets
    // Top-left
    canvas.drawLine(
      Offset(0, cornerLength),
      const Offset(0, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerLength, 0),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
