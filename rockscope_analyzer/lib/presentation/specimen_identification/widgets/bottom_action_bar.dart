import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback? onSaveIdentification;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onShareResults;
  final bool isIdentificationAvailable;

  const BottomActionBar({
    super.key,
    this.onSaveIdentification,
    this.onAddToCollection,
    this.onShareResults,
    this.isIdentificationAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Save Identification button
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    isIdentificationAvailable ? onSaveIdentification : null,
                icon: CustomIconWidget(
                  iconName: 'save',
                  color: isIdentificationAvailable
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18,
                ),
                label: Text('Save ID'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIdentificationAvailable
                      ? colorScheme.primary
                      : colorScheme.surface,
                  foregroundColor: isIdentificationAvailable
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isIdentificationAvailable
                          ? Colors.transparent
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Add to Collection button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isIdentificationAvailable ? onAddToCollection : null,
                icon: CustomIconWidget(
                  iconName: 'folder_open',
                  color: isIdentificationAvailable
                      ? colorScheme.onSecondary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 18,
                ),
                label: Text('Add to Collection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isIdentificationAvailable
                      ? colorScheme.secondary
                      : colorScheme.surface,
                  foregroundColor: isIdentificationAvailable
                      ? colorScheme.onSecondary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  padding: EdgeInsets.symmetric(vertical: 3.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isIdentificationAvailable
                          ? Colors.transparent
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Share Results button
            Container(
              decoration: BoxDecoration(
                color: isIdentificationAvailable
                    ? colorScheme.tertiary.withValues(alpha: 0.1)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isIdentificationAvailable
                      ? colorScheme.tertiary.withValues(alpha: 0.3)
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: IconButton(
                onPressed: isIdentificationAvailable ? onShareResults : null,
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: isIdentificationAvailable
                      ? colorScheme.tertiary
                      : colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20,
                ),
                padding: EdgeInsets.all(3.w),
                constraints: BoxConstraints(
                  minWidth: 12.w,
                  minHeight: 12.w,
                ),
                tooltip: 'Share Results',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
