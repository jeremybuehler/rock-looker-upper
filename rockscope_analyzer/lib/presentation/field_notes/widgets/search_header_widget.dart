import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for the sticky header containing search functionality and new note button
/// Optimized for field research with voice search and quick access controls
class SearchHeaderWidget extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNewNote;
  final VoidCallback onFilter;
  final bool hasActiveFilters;
  final VoidCallback? onVoiceSearch;

  const SearchHeaderWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onNewNote,
    required this.onFilter,
    this.hasActiveFilters = false,
    this.onVoiceSearch,
  });

  @override
  State<SearchHeaderWidget> createState() => _SearchHeaderWidgetState();
}

class _SearchHeaderWidgetState extends State<SearchHeaderWidget> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSearchField(context),
                ),
                SizedBox(width: 3.w),
                _buildFilterButton(context),
                SizedBox(width: 2.w),
                _buildNewNoteButton(context),
              ],
            ),
            if (_isSearchFocused) ...[
              SizedBox(height: 1.h),
              _buildSearchSuggestions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: _isSearchFocused
            ? Border.all(color: colorScheme.primary, width: 2)
            : Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: widget.onSearchChanged,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search notes, locations, specimens...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              size: 20,
              color: _isSearchFocused
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              if (widget.onVoiceSearch != null)
                IconButton(
                  onPressed: widget.onVoiceSearch,
                  icon: CustomIconWidget(
                    iconName: 'mic',
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Voice Search',
                ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _searchFocusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 6.h,
      width: 6.h,
      decoration: BoxDecoration(
        color: widget.hasActiveFilters
            ? colorScheme.primary
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.hasActiveFilters
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onFilter,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Center(
                child: CustomIconWidget(
                  iconName: 'tune',
                  size: 24,
                  color: widget.hasActiveFilters
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (widget.hasActiveFilters)
                Positioned(
                  top: 1.h,
                  right: 1.h,
                  child: Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewNoteButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onNewNote,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'add',
                size: 20,
                color: colorScheme.onPrimary,
              ),
              SizedBox(width: 2.w),
              Text(
                'New Note',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mock search suggestions based on common field research terms
    final suggestions = [
      'Marine specimens',
      'Rock formations',
      'GPS coordinates',
      'Weather conditions',
      'Team observations',
      'Artifact analysis',
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: 20.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            dense: true,
            leading: CustomIconWidget(
              iconName: 'history',
              size: 18,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            title: Text(
              suggestion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'north_west',
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () {
              _searchController.text = suggestion;
              widget.onSearchChanged(suggestion);
              _searchFocusNode.unfocus();
            },
          );
        },
      ),
    );
  }
}
