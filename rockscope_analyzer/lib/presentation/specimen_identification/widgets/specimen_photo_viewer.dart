import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SpecimenPhotoViewer extends StatefulWidget {
  final String? imageUrl;
  final String? imagePath;
  final VoidCallback? onRetakePhoto;

  const SpecimenPhotoViewer({
    super.key,
    this.imageUrl,
    this.imagePath,
    this.onRetakePhoto,
  });

  @override
  State<SpecimenPhotoViewer> createState() => _SpecimenPhotoViewerState();
}

class _SpecimenPhotoViewerState extends State<SpecimenPhotoViewer> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Photo viewer with zoom
            if (widget.imageUrl != null || widget.imagePath != null)
              InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomImageWidget(
                    imageUrl: widget.imageUrl ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              // Placeholder when no image
              Container(
                width: double.infinity,
                height: double.infinity,
                color: colorScheme.surface,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'photo_camera',
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No specimen photo available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    if (widget.onRetakePhoto != null)
                      TextButton(
                        onPressed: widget.onRetakePhoto,
                        child: Text('Take Photo'),
                      ),
                  ],
                ),
              ),

            // Zoom controls overlay
            if (widget.imageUrl != null || widget.imagePath != null)
              Positioned(
                top: 2.h,
                right: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: _zoomIn,
                        icon: CustomIconWidget(
                          iconName: 'zoom_in',
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.all(2.w),
                        constraints: BoxConstraints(
                          minWidth: 10.w,
                          minHeight: 10.w,
                        ),
                      ),
                      IconButton(
                        onPressed: _zoomOut,
                        icon: CustomIconWidget(
                          iconName: 'zoom_out',
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.all(2.w),
                        constraints: BoxConstraints(
                          minWidth: 10.w,
                          minHeight: 10.w,
                        ),
                      ),
                      IconButton(
                        onPressed: _resetZoom,
                        icon: CustomIconWidget(
                          iconName: 'center_focus_strong',
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.all(2.w),
                        constraints: BoxConstraints(
                          minWidth: 10.w,
                          minHeight: 10.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Retake photo button
            if (widget.onRetakePhoto != null &&
                (widget.imageUrl != null || widget.imagePath != null))
              Positioned(
                top: 2.h,
                left: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: widget.onRetakePhoto,
                    icon: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.all(2.w),
                    constraints: BoxConstraints(
                      minWidth: 10.w,
                      minHeight: 10.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _zoomIn() {
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.scale(1.2);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final Matrix4 matrix = _transformationController.value.clone();
    matrix.scale(0.8);
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }
}
