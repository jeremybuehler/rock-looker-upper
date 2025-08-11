import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Zoom control widget for macro photography
class ZoomControlWidget extends StatelessWidget {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final bool isVisible;
  final Function(double)? onZoomChanged;

  const ZoomControlWidget({
    super.key,
    this.currentZoom = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 10.0,
    this.isVisible = false,
    this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      right: 4.w,
      top: 20.h,
      bottom: 30.h,
      child: Container(
        width: 12.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Zoom in button
            _buildZoomButton(
              icon: 'add',
              onTap: () => _adjustZoom(0.5),
            ),

            // Zoom slider
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: currentZoom,
                    min: minZoom,
                    max: maxZoom,
                    divisions: ((maxZoom - minZoom) * 2).round(),
                    activeColor: AppTheme.lightTheme.colorScheme.tertiary,
                    inactiveColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: AppTheme.lightTheme.colorScheme.tertiary,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      onZoomChanged?.call(value);
                    },
                  ),
                ),
              ),
            ),

            // Zoom out button
            _buildZoomButton(
              icon: 'remove',
              onTap: () => _adjustZoom(-0.5),
            ),

            // Zoom level indicator
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                '${currentZoom.toStringAsFixed(1)}x',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 10.w,
        height: 10.w,
        margin: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 5.w,
          ),
        ),
      ),
    );
  }

  void _adjustZoom(double delta) {
    final newZoom = (currentZoom + delta).clamp(minZoom, maxZoom);
    onZoomChanged?.call(newZoom);
  }
}
