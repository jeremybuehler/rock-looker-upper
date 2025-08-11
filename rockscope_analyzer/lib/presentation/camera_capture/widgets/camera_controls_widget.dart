import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Camera control buttons widget for top toolbar
class CameraControlsWidget extends StatelessWidget {
  final bool isFlashOn;
  final bool isFrontCamera;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onCameraFlip;
  final VoidCallback? onClose;

  const CameraControlsWidget({
    super.key,
    this.isFlashOn = false,
    this.isFrontCamera = false,
    this.onFlashToggle,
    this.onCameraFlip,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flash toggle button
            _buildControlButton(
              icon: isFlashOn ? 'flash_on' : 'flash_off',
              onTap: () {
                HapticFeedback.lightImpact();
                onFlashToggle?.call();
              },
              tooltip: isFlashOn ? 'Turn off flash' : 'Turn on flash',
            ),

            // Camera flip button
            _buildControlButton(
              icon: 'flip_camera_ios',
              onTap: () {
                HapticFeedback.lightImpact();
                onCameraFlip?.call();
              },
              tooltip: 'Switch camera',
            ),

            // Close button
            _buildControlButton(
              icon: 'close',
              onTap: () {
                HapticFeedback.lightImpact();
                onClose?.call();
              },
              tooltip: 'Close camera',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: Colors.white,
              size: 6.w,
            ),
          ),
        ),
      ),
    );
  }
}
