import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying search suggestions and category shortcuts
/// Shown when search is empty or no results found
class SearchSuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final List<Map<String, dynamic>> categoryShortcuts;
  final ValueChanged<String> onSuggestionTap;
  final ValueChanged<String> onCategoryTap;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.categoryShortcuts,
    required this.onSuggestionTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches or suggestions
          if (suggestions.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            ...suggestions.take(5).map((suggestion) => _buildSuggestionItem(
                  context,
                  suggestion,
                  Icons.history,
                  () => onSuggestionTap(suggestion),
                )),
            SizedBox(height: 3.h),
          ],

          // Category shortcuts
          Text(
            'Browse by Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 3,
            ),
            itemCount: categoryShortcuts.length,
            itemBuilder: (context, index) {
              final category = categoryShortcuts[index];
              return _buildCategoryShortcut(
                context,
                category["name"] as String,
                category["icon"] as IconData,
                category["count"] as int,
                () => onCategoryTap(category["name"] as String),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String suggestion,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                suggestion,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'north_west',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryShortcut(
    BuildContext context,
    String name,
    IconData icon,
    int count,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: _getIconName(icon),
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$count items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    // Map IconData to string names for CustomIconWidget
    if (icon == Icons.landscape) return 'landscape';
    if (icon == Icons.waves) return 'waves';
    if (icon == Icons.local_florist) return 'local_florist';
    if (icon == Icons.museum) return 'museum';
    if (icon == Icons.science) return 'science';
    if (icon == Icons.category) return 'category';
    return 'category'; // default fallback
  }
}
