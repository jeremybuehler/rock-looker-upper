import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ManualSearchTab extends StatefulWidget {
  final Function(String) onSearch;
  final Function(Map<String, String>) onFiltersChanged;

  const ManualSearchTab({
    super.key,
    required this.onSearch,
    required this.onFiltersChanged,
  });

  @override
  State<ManualSearchTab> createState() => _ManualSearchTabState();
}

class _ManualSearchTabState extends State<ManualSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _selectedFilters = {};

  final Map<String, List<String>> _filterOptions = {
    'Rock Type': [
      'Igneous',
      'Sedimentary',
      'Metamorphic',
      'Volcanic',
      'Plutonic'
    ],
    'Geological Period': [
      'Precambrian',
      'Paleozoic',
      'Mesozoic',
      'Cenozoic',
      'Quaternary'
    ],
    'Formation Environment': [
      'Marine',
      'Continental',
      'Volcanic',
      'Hydrothermal',
      'Weathering'
    ],
    'Geographic Region': [
      'Atlantic Coast',
      'Pacific Coast',
      'Gulf Coast',
      'Great Lakes',
      'Arctic'
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar with voice input
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search specimens, minerals, artifacts...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _startVoiceSearch,
                      icon: CustomIconWidget(
                        iconName: 'mic',
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      tooltip: 'Voice Search',
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch('');
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ),
                  ],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 3.h,
                ),
              ),
              onChanged: widget.onSearch,
              onSubmitted: widget.onSearch,
            ),
          ),

          SizedBox(height: 3.h),

          // Filter sections
          ...(_filterOptions.entries
              .map((entry) => _buildFilterSection(
                    context,
                    entry.key,
                    entry.value,
                    colorScheme,
                    theme,
                  ))
              .toList()),

          SizedBox(height: 2.h),

          // Active filters summary
          if (_selectedFilters.isNotEmpty) ...[
            Text(
              'Active Filters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _selectedFilters.entries.map((entry) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entry.key}: ${entry.value}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: () => _removeFilter(entry.key),
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: colorScheme.primary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),

            // Clear all filters button
            TextButton(
              onPressed: _clearAllFilters,
              child: Text('Clear All Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String title,
    List<String> options,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = _selectedFilters[title] == option;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) => _toggleFilter(title, option, selected),
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: colorScheme.primary,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  void _toggleFilter(String category, String option, bool selected) {
    setState(() {
      if (selected) {
        _selectedFilters[category] = option;
      } else {
        _selectedFilters.remove(category);
      }
    });
    widget.onFiltersChanged(_selectedFilters);
  }

  void _removeFilter(String category) {
    setState(() {
      _selectedFilters.remove(category);
    });
    widget.onFiltersChanged(_selectedFilters);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
    });
    widget.onFiltersChanged(_selectedFilters);
  }

  void _startVoiceSearch() {
    // Voice search implementation would go here
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
