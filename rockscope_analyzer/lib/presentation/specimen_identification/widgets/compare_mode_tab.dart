import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CompareModeTab extends StatefulWidget {
  final String? specimenImageUrl;
  final List<Map<String, dynamic>> comparisonCandidates;
  final Function(Map<String, dynamic>) onCandidateSelected;

  const CompareModeTab({
    super.key,
    this.specimenImageUrl,
    required this.comparisonCandidates,
    required this.onCandidateSelected,
  });

  @override
  State<CompareModeTab> createState() => _CompareModeTabState();
}

class _CompareModeTabState extends State<CompareModeTab> {
  int _currentCandidateIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.comparisonCandidates.isEmpty) {
      return _buildEmptyState(context, theme, colorScheme);
    }

    return Column(
      children: [
        // Split-screen comparison view
        Expanded(
          flex: 3,
          child: Container(
            margin: EdgeInsets.all(4.w),
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
              child: Row(
                children: [
                  // Specimen image (left side)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'photo_camera',
                                  color: colorScheme.primary,
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Your Specimen',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: widget.specimenImageUrl != null
                                ? CustomImageWidget(
                                    imageUrl: widget.specimenImageUrl!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: colorScheme.surface,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'photo_camera',
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                          size: 32,
                                        ),
                                        SizedBox(height: 1.h),
                                        Text(
                                          'No specimen\nimage available',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Database candidate (right side)
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          color: colorScheme.secondary.withValues(alpha: 0.1),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'library_books',
                                color: colorScheme.secondary,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  'Database Match',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentCandidateIndex = index;
                              });
                            },
                            itemCount: widget.comparisonCandidates.length,
                            itemBuilder: (context, index) {
                              final candidate =
                                  widget.comparisonCandidates[index];
                              return CustomImageWidget(
                                imageUrl: candidate['imageUrl'] as String,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Candidate information and controls
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                // Candidate details
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.comparisonCandidates[_currentCandidateIndex]
                            ['scientificName'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.comparisonCandidates[_currentCandidateIndex]
                            ['commonName'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.comparisonCandidates[
                                  _currentCandidateIndex]['category'] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Match: ${((widget.comparisonCandidates[_currentCandidateIndex]['confidence'] as double) * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // Navigation controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    ElevatedButton.icon(
                      onPressed: _currentCandidateIndex > 0
                          ? _previousCandidate
                          : null,
                      icon: CustomIconWidget(
                        iconName: 'arrow_back_ios',
                        color: _currentCandidateIndex > 0
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 16,
                      ),
                      label: Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentCandidateIndex > 0
                            ? colorScheme.primary
                            : colorScheme.surface,
                        foregroundColor: _currentCandidateIndex > 0
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),

                    // Page indicator
                    Text(
                      '${_currentCandidateIndex + 1} of ${widget.comparisonCandidates.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),

                    // Next button
                    ElevatedButton.icon(
                      onPressed: _currentCandidateIndex <
                              widget.comparisonCandidates.length - 1
                          ? _nextCandidate
                          : null,
                      icon: CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: _currentCandidateIndex <
                                widget.comparisonCandidates.length - 1
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                        size: 16,
                      ),
                      label: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentCandidateIndex <
                                widget.comparisonCandidates.length - 1
                            ? colorScheme.primary
                            : colorScheme.surface,
                        foregroundColor: _currentCandidateIndex <
                                widget.comparisonCandidates.length - 1
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Select candidate button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onCandidateSelected(
                      widget.comparisonCandidates[_currentCandidateIndex],
                    ),
                    child: Text('Select This Match'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'compare',
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No comparison candidates available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Run AI analysis or manual search to find specimens for comparison',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _previousCandidate() {
    if (_currentCandidateIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextCandidate() {
    if (_currentCandidateIndex < widget.comparisonCandidates.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
