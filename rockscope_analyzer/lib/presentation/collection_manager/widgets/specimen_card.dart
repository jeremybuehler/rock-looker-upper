import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SpecimenCard extends StatelessWidget {
  final Map<String, dynamic> specimen;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAddNotes;
  final VoidCallback? onViewLocation;
  final VoidCallback? onRemove;
  final VoidCallback? onShare;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;

  const SpecimenCard({
    super.key,
    required this.specimen,
    this.onTap,
    this.onEdit,
    this.onAddNotes,
    this.onViewLocation,
    this.onRemove,
    this.onShare,
    this.isSelected = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String name = specimen['name'] as String? ?? 'Unknown Specimen';
    final double confidence =
        (specimen['confidence'] as num?)?.toDouble() ?? 0.0;
    final String location =
        specimen['location'] as String? ?? 'Unknown Location';
    final String date = specimen['date'] as String? ?? 'Unknown Date';
    final String imageUrl = specimen['imageUrl'] as String? ?? '';
    final String status = specimen['status'] as String? ?? 'uncertain';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => onSelectionChanged?.call(!isSelected),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (onSelectionChanged != null)
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) => onSelectionChanged?.call(value ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                _buildSpecimenImage(imageUrl),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(context, status, confidence),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      _buildConfidenceBar(context, confidence),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              location,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'calendar_today',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildActionMenu(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecimenImage(String imageUrl) {
    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withValues(alpha: 0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? CustomImageWidget(
                imageUrl: imageUrl,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.cover,
              )
            : CustomIconWidget(
                iconName: 'image',
                color: Colors.grey,
                size: 24,
              ),
      ),
    );
  }

  Widget _buildStatusBadge(
      BuildContext context, String status, double confidence) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeColor;
    String badgeText;

    switch (status.toLowerCase()) {
      case 'confirmed':
        badgeColor = AppTheme.getSuccessColor(isDark);
        badgeText = 'Confirmed';
        break;
      case 'probable':
        badgeColor = AppTheme.getWarningColor(isDark);
        badgeText = 'Probable';
        break;
      case 'uncertain':
      default:
        badgeColor = theme.colorScheme.error;
        badgeText = 'Uncertain';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        badgeText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(BuildContext context, double confidence) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color barColor;
    if (confidence >= 90) {
      barColor = AppTheme.getSuccessColor(isDark);
    } else if (confidence >= 70) {
      barColor = AppTheme.getWarningColor(isDark);
    } else {
      barColor = theme.colorScheme.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${confidence.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: barColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence / 100,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: CustomIconWidget(
        iconName: 'more_vert',
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        size: 20,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'notes':
            onAddNotes?.call();
            break;
          case 'location':
            onViewLocation?.call();
            break;
          case 'remove':
            onRemove?.call();
            break;
          case 'share':
            onShare?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'edit',
                color: theme.colorScheme.onSurface,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text('Edit Identification'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'notes',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'note_add',
                color: theme.colorScheme.onSurface,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text('Add Notes'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'location',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.onSurface,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text('View Location'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'share',
                color: theme.colorScheme.primary,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text('Share'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'delete',
                color: theme.colorScheme.error,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text('Remove'),
            ],
          ),
        ),
      ],
    );
  }
}