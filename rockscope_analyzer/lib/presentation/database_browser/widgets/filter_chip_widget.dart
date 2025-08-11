import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying active filter chips with count badges
/// Allows users to see and remove active filters
class FilterChipWidget extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onRemove;
  final Color? backgroundColor;
  final Color? textColor;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.count,
    required this.onRemove,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 1.5.w,
                  vertical: 0.2.h,
                ),
                decoration: BoxDecoration(
                  color: (textColor ?? colorScheme.onPrimary)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor ?? colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: backgroundColor ?? colorScheme.primary,
        deleteIcon: CustomIconWidget(
          iconName: 'close',
          color: textColor ?? colorScheme.onPrimary,
          size: 16,
        ),
        onDeleted: onRemove,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
