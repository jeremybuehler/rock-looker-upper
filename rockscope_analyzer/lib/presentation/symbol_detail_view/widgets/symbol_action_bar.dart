import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SymbolActionBar extends StatelessWidget {
  final Map<String, dynamic> symbolData;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onCompareSimilar;
  final VoidCallback? onShare;
  final VoidCallback? onFieldNotes;

  const SymbolActionBar({
    super.key,
    required this.symbolData,
    this.onAddToCollection,
    this.onCompareSimilar,
    this.onShare,
    this.onFieldNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: 'add_circle_outline',
                label: 'Add to Collection',
                onTap: () {
                  HapticFeedback.lightImpact();
                  onAddToCollection?.call();
                  _showAddedToCollectionSnackBar(context);
                },
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildActionButton(
                icon: 'compare_arrows',
                label: 'Compare Similar',
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCompareSimilar?.call();
                  Navigator.pushNamed(context, '/database-browser');
                },
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildActionButton(
                icon: 'share',
                label: 'Share',
                onTap: () {
                  HapticFeedback.lightImpact();
                  onShare?.call();
                  _showShareBottomSheet(context);
                },
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildActionButton(
                icon: 'note_add',
                label: 'Field Notes',
                onTap: () {
                  HapticFeedback.lightImpact();
                  onFieldNotes?.call();
                  Navigator.pushNamed(context, '/field-notes');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: AppTheme.lightTheme.primaryColor,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddedToCollectionSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 2.w),
            Text(
              'Added to collection successfully',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        backgroundColor: AppTheme.getSuccessColor(true),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Specimen Data',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _buildShareOption(
                      context,
                      icon: 'email',
                      title: 'Email Report',
                      subtitle: 'Send detailed specimen report',
                      onTap: () {
                        Navigator.pop(context);
                        _shareViaEmail(context);
                      },
                    ),
                    _buildShareOption(
                      context,
                      icon: 'link',
                      title: 'Copy Link',
                      subtitle: 'Copy specimen reference link',
                      onTap: () {
                        Navigator.pop(context);
                        _copyToClipboard(context);
                      },
                    ),
                    _buildShareOption(
                      context,
                      icon: 'file_download',
                      title: 'Export Data',
                      subtitle: 'Download as PDF or CSV',
                      onTap: () {
                        Navigator.pop(context);
                        _exportData(context);
                      },
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            size: 24,
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      onTap: onTap,
    );
  }

  void _shareViaEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening email client...',
          style: TextStyle(fontSize: 14.sp),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final specimenUrl =
        'https://rockscope.app/specimen/${symbolData['id'] ?? 'unknown'}';
    Clipboard.setData(ClipboardData(text: specimenUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'content_copy',
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 2.w),
            Text(
              'Link copied to clipboard',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Export Format',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'picture_as_pdf',
                size: 24,
                color: Colors.red,
              ),
              title: Text('PDF Report'),
              subtitle: Text('Detailed specimen report'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPDF(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'table_chart',
                size: 24,
                color: Colors.green,
              ),
              title: Text('CSV Data'),
              subtitle: Text('Raw data for analysis'),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _exportAsPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating PDF report...',
          style: TextStyle(fontSize: 14.sp),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _exportAsCSV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exporting CSV data...',
          style: TextStyle(fontSize: 14.sp),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
