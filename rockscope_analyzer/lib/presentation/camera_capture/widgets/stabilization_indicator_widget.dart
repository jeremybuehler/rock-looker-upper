import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Camera stabilization indicator widget
class StabilizationIndicatorWidget extends StatefulWidget {
  final bool isStable;
  final double stabilityLevel; // 0.0 to 1.0
  final bool isVisible;

  const StabilizationIndicatorWidget({
    super.key,
    this.isStable = false,
    this.stabilityLevel = 0.0,
    this.isVisible = false,
  });

  @override
  State<StabilizationIndicatorWidget> createState() =>
      _StabilizationIndicatorWidgetState();
}

class _StabilizationIndicatorWidgetState
    extends State<StabilizationIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (!widget.isStable) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StabilizationIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStable != oldWidget.isStable) {
      if (widget.isStable) {
        _pulseController.stop();
        _pulseController.reset();
      } else {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned(
      left: 4.w,
      bottom: 35.h,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isStable ? 1.0 : _pulseAnimation.value,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: widget.isStable
                    ? AppTheme.getSuccessColor(true).withValues(alpha: 0.9)
                    : AppTheme.getWarningColor(true).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: widget.isStable ? 'check_circle' : 'warning',
                    color: Colors.white,
                    size: 6.w,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    widget.isStable ? 'Stable' : 'Hold Steady',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildStabilityMeter(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStabilityMeter() {
    return Container(
      width: 15.w,
      height: 1.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.stabilityLevel,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isStable
                ? Colors.white
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
