import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet widget for advanced filtering options
/// Provides collapsible sections for different filter categories
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, List<String>> selectedFilters;
  final ValueChanged<Map<String, List<String>>> onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, List<String>> _currentFilters;
  final Map<String, bool> _expandedSections = {
    'Rock Types': true,
    'Geological Periods': false,
    'Formation Environments': false,
    'Geographic Regions': false,
    'Chemical Composition': false,
  };

  final Map<String, List<String>> _filterOptions = {
    'Rock Types': [
      'Igneous',
      'Sedimentary',
      'Metamorphic',
      'Volcanic',
      'Plutonic',
      'Clastic',
      'Chemical',
      'Organic',
    ],
    'Geological Periods': [
      'Precambrian',
      'Cambrian',
      'Ordovician',
      'Silurian',
      'Devonian',
      'Carboniferous',
      'Permian',
      'Triassic',
      'Jurassic',
      'Cretaceous',
      'Paleogene',
      'Neogene',
      'Quaternary',
    ],
    'Formation Environments': [
      'Marine',
      'Continental',
      'Transitional',
      'Deep Ocean',
      'Shallow Sea',
      'River Delta',
      'Desert',
      'Glacial',
      'Volcanic',
      'Hydrothermal',
    ],
    'Geographic Regions': [
      'Atlantic Ocean',
      'Pacific Ocean',
      'Indian Ocean',
      'Arctic Ocean',
      'Mediterranean Sea',
      'Caribbean Sea',
      'North Sea',
      'Baltic Sea',
      'Red Sea',
      'Persian Gulf',
    ],
    'Chemical Composition': [
      'Silicate',
      'Carbonate',
      'Sulfate',
      'Phosphate',
      'Oxide',
      'Sulfide',
      'Halide',
      'Native Element',
      'Organic',
      'Clay Mineral',
    ],
  };

  @override
  void initState() {
    super.initState();
    _currentFilters = Map.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: 80.h,
        minHeight: 50.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Database',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: Text(
                        'Clear All',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onFiltersChanged(_currentFilters);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Apply',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Divider(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            height: 1,
          ),

          // Filter sections
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              children: _filterOptions.entries.map((entry) {
                return _buildFilterSection(
                  context,
                  entry.key,
                  entry.value,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String sectionTitle,
    List<String> options,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpanded = _expandedSections[sectionTitle] ?? false;
    final selectedOptions = _currentFilters[sectionTitle] ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Section header
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedSections[sectionTitle] = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        sectionTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (selectedOptions.isNotEmpty) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            selectedOptions.length.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Section content
          if (isExpanded) ...[
            Divider(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              height: 1,
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: options.map((option) {
                  final isSelected = selectedOptions.contains(option);

                  return GestureDetector(
                    onTap: () => _toggleFilter(sectionTitle, option),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        option,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleFilter(String section, String option) {
    setState(() {
      if (_currentFilters[section] == null) {
        _currentFilters[section] = [];
      }

      if (_currentFilters[section]!.contains(option)) {
        _currentFilters[section]!.remove(option);
        if (_currentFilters[section]!.isEmpty) {
          _currentFilters.remove(section);
        }
      } else {
        _currentFilters[section]!.add(option);
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters.clear();
    });
  }
}
