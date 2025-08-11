import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet widget for filtering field notes by various criteria
/// including date range, location, specimen type, and team members
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>> onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;
  double _locationRadius = 10.0;
  List<String> _selectedSpecimenTypes = [];
  List<String> _selectedTeamMembers = [];
  String _selectedSyncStatus = 'all';

  final List<String> _specimenTypes = [
    'Marine Life',
    'Rock Formations',
    'Minerals',
    'Fossils',
    'Artifacts',
    'Sediments',
    'Coral',
    'Shells',
    'Unknown',
  ];

  final List<Map<String, dynamic>> _teamMembers = [
    {"id": "1", "name": "Dr. Sarah Chen", "role": "Lead Researcher"},
    {"id": "2", "name": "Marcus Rodriguez", "role": "Marine Biologist"},
    {"id": "3", "name": "Dr. Emily Watson", "role": "Geologist"},
    {"id": "4", "name": "James Park", "role": "Field Assistant"},
    {"id": "5", "name": "Dr. Lisa Thompson", "role": "Archaeologist"},
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _initializeFilters();
  }

  void _initializeFilters() {
    _selectedDateRange = _filters['dateRange'] as DateTimeRange?;
    _locationRadius = (_filters['locationRadius'] as double?) ?? 10.0;
    _selectedSpecimenTypes = List<String>.from(_filters['specimenTypes'] ?? []);
    _selectedTeamMembers = List<String>.from(_filters['teamMembers'] ?? []);
    _selectedSyncStatus = _filters['syncStatus'] as String? ?? 'all';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateRangeFilter(context),
                  SizedBox(height: 3.h),
                  _buildLocationFilter(context),
                  SizedBox(height: 3.h),
                  _buildSpecimenTypeFilter(context),
                  SizedBox(height: 3.h),
                  _buildTeamMemberFilter(context),
                  SizedBox(height: 3.h),
                  _buildSyncStatusFilter(context),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filter Notes',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Clear All',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CustomIconWidget(
              iconName: 'close',
              size: 24,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: _selectDateRange,
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'date_range',
                  size: 20,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _selectedDateRange != null
                        ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                        : 'Select date range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedDateRange != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                if (_selectedDateRange != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      size: 18,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location Radius',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              size: 20,
              color: colorScheme.primary,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Slider(
                value: _locationRadius,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                label: '${_locationRadius.round()} km',
                onChanged: (value) {
                  setState(() {
                    _locationRadius = value;
                  });
                },
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              '${_locationRadius.round()} km',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecimenTypeFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specimen Types',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _specimenTypes.map((type) {
            final isSelected = _selectedSpecimenTypes.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecimenTypes.add(type);
                  } else {
                    _selectedSpecimenTypes.remove(type);
                  }
                });
              },
              backgroundColor: colorScheme.surfaceContainerHigh,
              selectedColor: colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: colorScheme.primary,
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTeamMemberFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Members',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...(_teamMembers.map((member) {
          final isSelected = _selectedTeamMembers.contains(member["id"]);
          return CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedTeamMembers.add(member["id"] as String);
                } else {
                  _selectedTeamMembers.remove(member["id"]);
                }
              });
            },
            title: Text(
              member["name"] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Text(
              member["role"] as String,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        })),
      ],
    );
  }

  Widget _buildSyncStatusFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final syncOptions = [
      {'value': 'all', 'label': 'All Notes', 'icon': 'notes'},
      {'value': 'synced', 'label': 'Synced', 'icon': 'cloud_done'},
      {'value': 'pending', 'label': 'Pending Sync', 'icon': 'cloud_upload'},
      {'value': 'offline', 'label': 'Offline Only', 'icon': 'cloud_off'},
      {'value': 'error', 'label': 'Sync Error', 'icon': 'sync_problem'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync Status',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...syncOptions.map((option) {
          final isSelected = _selectedSyncStatus == option['value'];
          return RadioListTile<String>(
            value: option['value'] as String,
            groupValue: _selectedSyncStatus,
            onChanged: (value) {
              setState(() {
                _selectedSyncStatus = value ?? 'all';
              });
            },
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: option['icon'] as String,
                  size: 18,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                SizedBox(width: 3.w),
                Text(
                  option['label'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                side: BorderSide(color: colorScheme.outline),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(
                'Apply Filters',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDateRange = null;
      _locationRadius = 10.0;
      _selectedSpecimenTypes.clear();
      _selectedTeamMembers.clear();
      _selectedSyncStatus = 'all';
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'dateRange': _selectedDateRange,
      'locationRadius': _locationRadius,
      'specimenTypes': _selectedSpecimenTypes,
      'teamMembers': _selectedTeamMembers,
      'syncStatus': _selectedSyncStatus,
    };

    widget.onFiltersChanged(filters);
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }
}
