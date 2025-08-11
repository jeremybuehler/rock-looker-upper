import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SortOptionsSheet extends StatelessWidget {
  final String currentSortOption;
  final bool isAscending;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<bool> onOrderChanged;

  const SortOptionsSheet({
    super.key,
    required this.currentSortOption,
    required this.isAscending,
    required this.onSortChanged,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sortOptions = [
      {'key': 'date', 'title': 'Date Discovered', 'icon': 'calendar_today'},
      {'key': 'confidence', 'title': 'Confidence Score', 'icon': 'verified'},
      {'key': 'name', 'title': 'Alphabetical', 'icon': 'sort_by_alpha'},
      {'key': 'location', 'title': 'Location Proximity', 'icon': 'location_on'},
    ];

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Sort Options',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          ...sortOptions.map((option) => _buildSortOption(
                context,
                option['key'] as String,
                option['title'] as String,
                option['icon'] as String,
              )),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: isAscending ? 'arrow_upward' : 'arrow_downward',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    'Sort Order',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: isAscending,
                  onChanged: onOrderChanged,
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isAscending
                ? 'Ascending (A-Z, Low-High)'
                : 'Descending (Z-A, High-Low)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                'Close',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String key,
    String title,
    String iconName,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentSortOption == key;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onSortChanged(key);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary)
                  : null,
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 24,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  CustomIconWidget(
                    iconName: 'check',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
