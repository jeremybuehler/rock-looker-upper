import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Bottom capture controls widget with capture button and options
class CaptureControlsWidget extends StatelessWidget {
  final bool isMeasurementMode;
  final String? lastPhotoPath;
  final VoidCallback? onCapture;
  final VoidCallback? onGallery;
  final VoidCallback? onMeasurementToggle;

  const CaptureControlsWidget({
    super.key,
    this.isMeasurementMode = false,
    this.lastPhotoPath,
    this.onCapture,
    this.onGallery,
    this.onMeasurementToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gallery thumbnail
            _buildGalleryButton(),

            // Capture button
            _buildCaptureButton(),

            // Measurement mode toggle
            _buildMeasurementToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onGallery?.call();
      },
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: lastPhotoPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CustomImageWidget(
                  imageUrl: lastPhotoPath!,
                  width: 15.w,
                  height: 15.w,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: CustomIconWidget(
                  iconName: 'photo_library',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onCapture?.call();
      },
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onMeasurementToggle?.call();
      },
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: isMeasurementMode
              ? AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: isMeasurementMode
                ? AppTheme.lightTheme.colorScheme.tertiary
                : Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'straighten',
            color: isMeasurementMode
                ? AppTheme.lightTheme.colorScheme.tertiary
                : Colors.white,
            size: 6.w,
          ),
        ),
      ),
    );
  }
}
