import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for displaying individual field note cards with specimen thumbnails,
/// collaboration indicators, and swipe actions for comprehensive field research
class NoteCardWidget extends StatelessWidget {
  final Map<String, dynamic> noteData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onShare;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final bool isSelected;

  const NoteCardWidget({
    super.key,
    required this.noteData,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onShare,
    this.onArchive,
    this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key('note_${noteData["id"]}'),
      background: _buildRightSwipeBackground(context),
      secondaryBackground: _buildLeftSwipeBackground(context),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Right swipe - Edit action
          onEdit?.call();
        } else {
          // Left swipe - Delete action
          onDelete?.call();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Show confirmation for delete
          return await _showDeleteConfirmation(context);
        }
        return false; // Don't dismiss for edit, just trigger action
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Material(
          elevation: isSelected ? 4.0 : 2.0,
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surface,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNoteHeader(context),
                  SizedBox(height: 1.h),
                  _buildNoteContent(context),
                  if ((noteData["specimens"] as List?)?.isNotEmpty == true) ...[
                    SizedBox(height: 1.5.h),
                    _buildSpecimenThumbnails(context),
                  ],
                  SizedBox(height: 1.h),
                  _buildNoteFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                noteData["title"] as String? ?? "Untitled Note",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'access_time',
                    size: 14,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    _formatDate(noteData["date"] as DateTime?),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (noteData["isShared"] == true)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'people',
                  size: 12,
                  color: colorScheme.primary,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Team',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNoteContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (noteData["location"] != null) ...[
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                size: 16,
                color: colorScheme.primary,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  noteData["location"] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
        ],
        if (noteData["weather"] != null) ...[
          Row(
            children: [
              CustomIconWidget(
                iconName: _getWeatherIcon(
                    noteData["weather"]["condition"] as String?),
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              SizedBox(width: 1.w),
              Text(
                '${noteData["weather"]["temperature"]}°C, ${noteData["weather"]["condition"]}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
        ],
        Text(
          noteData["preview"] as String? ?? "No content available",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.4,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSpecimenThumbnails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final specimens = (noteData["specimens"] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attached Specimens (${specimens.length})',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 0.5.h),
        SizedBox(
          height: 12.w,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: specimens.length > 4 ? 4 : specimens.length,
            separatorBuilder: (context, index) => SizedBox(width: 2.w),
            itemBuilder: (context, index) {
              if (index == 3 && specimens.length > 4) {
                return _buildMoreThumbnail(context, specimens.length - 3);
              }
              return _buildSpecimenThumbnail(context, specimens[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecimenThumbnail(
      BuildContext context, Map<String, dynamic> specimen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: specimen["imageUrl"] != null
            ? CustomImageWidget(
                imageUrl: specimen["imageUrl"] as String,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              )
            : Container(
                color: colorScheme.surfaceContainerHighest,
                child: CustomIconWidget(
                  iconName: 'image',
                  size: 6.w,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
      ),
    );
  }

  Widget _buildMoreThumbnail(BuildContext context, int remainingCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '+$remainingCount',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        if (noteData["hasAudio"] == true) ...[
          CustomIconWidget(
            iconName: 'mic',
            size: 16,
            color: colorScheme.primary,
          ),
          SizedBox(width: 3.w),
        ],
        if (noteData["hasPhotos"] == true) ...[
          CustomIconWidget(
            iconName: 'photo_camera',
            size: 16,
            color: colorScheme.primary,
          ),
          SizedBox(width: 3.w),
        ],
        if (noteData["syncStatus"] != null) ...[
          CustomIconWidget(
            iconName: _getSyncIcon(noteData["syncStatus"] as String),
            size: 16,
            color: _getSyncColor(context, noteData["syncStatus"] as String),
          ),
          SizedBox(width: 1.w),
          Text(
            _getSyncText(noteData["syncStatus"] as String),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getSyncColor(context, noteData["syncStatus"] as String),
            ),
          ),
        ],
        const Spacer(),
        if (noteData["collaborators"] != null &&
            (noteData["collaborators"] as List).isNotEmpty)
          Row(
            children: [
              ...((noteData["collaborators"] as List).take(3).map(
                    (collaborator) => Container(
                      margin: EdgeInsets.only(left: 1.w),
                      child: CircleAvatar(
                        radius: 3.w,
                        backgroundColor:
                            colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          (collaborator["name"] as String)
                              .substring(0, 1)
                              .toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )),
              if ((noteData["collaborators"] as List).length > 3)
                Container(
                  margin: EdgeInsets.only(left: 1.w),
                  child: CircleAvatar(
                    radius: 3.w,
                    backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                    child: Text(
                      '+${(noteData["collaborators"] as List).length - 3}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildRightSwipeBackground(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(width: 6.w),
          CustomIconWidget(
            iconName: 'edit',
            size: 24,
            color: colorScheme.onPrimary,
          ),
          SizedBox(width: 2.w),
          Text(
            'Edit',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6.w),
          CustomIconWidget(
            iconName: 'content_copy',
            size: 24,
            color: colorScheme.onPrimary,
          ),
          SizedBox(width: 2.w),
          Text(
            'Duplicate',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6.w),
          CustomIconWidget(
            iconName: 'share',
            size: 24,
            color: colorScheme.onPrimary,
          ),
          SizedBox(width: 2.w),
          Text(
            'Share',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSwipeBackground(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Archive',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onError,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: 'archive',
            size: 24,
            color: colorScheme.onError,
          ),
          SizedBox(width: 6.w),
          Text(
            'Delete',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onError,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: 'delete',
            size: 24,
            color: colorScheme.onError,
          ),
          SizedBox(width: 6.w),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Note',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${noteData["title"]}"? This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _getWeatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return 'wb_sunny';
      case 'cloudy':
      case 'overcast':
        return 'cloud';
      case 'rainy':
      case 'rain':
        return 'grain';
      case 'stormy':
        return 'thunderstorm';
      case 'windy':
        return 'air';
      case 'foggy':
        return 'foggy';
      default:
        return 'wb_cloudy';
    }
  }

  String _getSyncIcon(String status) {
    switch (status) {
      case 'synced':
        return 'cloud_done';
      case 'pending':
        return 'cloud_upload';
      case 'offline':
        return 'cloud_off';
      case 'error':
        return 'sync_problem';
      default:
        return 'sync';
    }
  }

  Color _getSyncColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'synced':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'offline':
        return colorScheme.onSurface.withValues(alpha: 0.5);
      case 'error':
        return colorScheme.error;
      default:
        return colorScheme.primary;
    }
  }

  String _getSyncText(String status) {
    switch (status) {
      case 'synced':
        return 'Synced';
      case 'pending':
        return 'Pending';
      case 'offline':
        return 'Offline';
      case 'error':
        return 'Error';
      default:
        return 'Sync';
    }
  }
}
