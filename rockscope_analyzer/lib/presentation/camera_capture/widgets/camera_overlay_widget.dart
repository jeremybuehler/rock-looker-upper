import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Camera overlay widget with measurement tools and grid lines
class CameraOverlayWidget extends StatelessWidget {
  final bool showGrid;
  final bool showMeasurementTools;
  final VoidCallback? onGridToggle;
  final VoidCallback? onMeasurementToggle;

  const CameraOverlayWidget({
    super.key,
    this.showGrid = false,
    this.showMeasurementTools = false,
    this.onGridToggle,
    this.onMeasurementToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid overlay
        if (showGrid) _buildGridOverlay(),

        // Measurement tools overlay
        if (showMeasurementTools) _buildMeasurementOverlay(),

        // Focus indicator (will be positioned dynamically)
        _buildFocusIndicator(),
      ],
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      size: Size.infinite,
      painter: GridOverlayPainter(),
    );
  }

  Widget _buildMeasurementOverlay() {
    return Stack(
      children: [
        // Ruler scale on the left
        Positioned(
          left: 2.w,
          top: 15.h,
          bottom: 25.h,
          child: Container(
            width: 4.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(2),
            ),
            child: CustomPaint(
              painter: RulerPainter(),
            ),
          ),
        ),

        // Size reference circle in center
        Center(
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '2cm',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusIndicator() {
    return Container(); // Will be positioned dynamically by parent
  }
}

/// Custom painter for grid overlay
class GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for ruler scale
class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw ruler marks
    for (int i = 0; i <= 10; i++) {
      final y = size.height * i / 10;
      final isMainMark = i % 5 == 0;
      final markWidth = isMainMark ? size.width * 0.6 : size.width * 0.3;

      canvas.drawLine(
        Offset(size.width - markWidth, y),
        Offset(size.width, y),
        paint,
      );

      // Add numbers for main marks
      if (isMainMark && i > 0) {
        textPainter.text = TextSpan(
          text: '${i}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width - markWidth - 12, y - textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
