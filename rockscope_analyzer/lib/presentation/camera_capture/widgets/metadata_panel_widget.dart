import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Side panel widget for metadata quick-entry
class MetadataPanelWidget extends StatefulWidget {
  final bool isVisible;
  final String? currentLocation;
  final String? selectedSpecimenType;
  final bool isRecording;
  final VoidCallback? onClose;
  final Function(String)? onSpecimenTypeSelected;
  final VoidCallback? onLocationRefresh;
  final VoidCallback? onVoiceNoteToggle;

  const MetadataPanelWidget({
    super.key,
    this.isVisible = false,
    this.currentLocation,
    this.selectedSpecimenType,
    this.isRecording = false,
    this.onClose,
    this.onSpecimenTypeSelected,
    this.onLocationRefresh,
    this.onVoiceNoteToggle,
  });

  @override
  State<MetadataPanelWidget> createState() => _MetadataPanelWidgetState();
}

class _MetadataPanelWidgetState extends State<MetadataPanelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> specimenTypes = [
    {
      "id": "marine_rock",
      "name": "Marine Rock",
      "icon": "waves",
      "color": Color(0xFF2E7D8A),
    },
    {
      "id": "sedimentary",
      "name": "Sedimentary",
      "icon": "layers",
      "color": Color(0xFF8B5A3C),
    },
    {
      "id": "volcanic",
      "name": "Volcanic",
      "icon": "local_fire_department",
      "color": Color(0xFFDC2626),
    },
    {
      "id": "artifact",
      "name": "Artifact",
      "icon": "museum",
      "color": Color(0xFF7C3AED),
    },
    {
      "id": "fossil",
      "name": "Fossil",
      "icon": "bug_report",
      "color": Color(0xFF059669),
    },
    {
      "id": "mineral",
      "name": "Mineral",
      "icon": "diamond",
      "color": Color(0xFFD97706),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MetadataPanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: 80.w,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSpecimenTypeSection(),
                      SizedBox(height: 4.h),
                      _buildLocationSection(),
                      SizedBox(height: 4.h),
                      _buildVoiceNoteSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Metadata Entry',
            style: TextStyle(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onClose?.call();
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecimenTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specimen Type',
          style: TextStyle(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: specimenTypes.map((type) {
            final isSelected = widget.selectedSpecimenType == type["id"];
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onSpecimenTypeSelected?.call(type["id"]);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (type["color"] as Color).withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? (type["color"] as Color)
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: type["icon"],
                      color: isSelected
                          ? (type["color"] as Color)
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      type["name"],
                      style: TextStyle(
                        color: isSelected
                            ? (type["color"] as Color)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GPS Location',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onLocationRefresh?.call();
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  widget.currentLocation ?? 'Getting location...',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice Notes',
          style: TextStyle(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onVoiceNoteToggle?.call();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: widget.isRecording
                  ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
              border: Border.all(
                color: widget.isRecording
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: widget.isRecording ? 'stop' : 'mic',
                  color: widget.isRecording
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  widget.isRecording ? 'Stop Recording' : 'Start Recording',
                  style: TextStyle(
                    color: widget.isRecording
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
