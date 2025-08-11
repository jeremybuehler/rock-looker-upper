import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RelatedSpecimensSection extends StatelessWidget {
  final String currentSpecimenId;

  const RelatedSpecimensSection({
    super.key,
    required this.currentSpecimenId,
  });

  @override
  Widget build(BuildContext context) {
    final relatedSpecimens = _getRelatedSpecimens();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Related Specimens',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/database-browser');
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 28.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: relatedSpecimens.length,
              itemBuilder: (context, index) {
                final specimen = relatedSpecimens[index];
                return _buildRelatedSpecimenCard(context, specimen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedSpecimenCard(
      BuildContext context, Map<String, dynamic> specimen) {
    return Container(
      width: 45.w,
      margin: EdgeInsets.only(right: 3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/symbol-detail-view',
                  arguments: {'specimenId': specimen['id']},
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CustomImageWidget(
                    imageUrl: specimen['image'] ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    specimen['name'] ?? 'Unknown Specimen',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    specimen['scientificName'] ?? 'Scientific name unknown',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color:
                              _getSimilarityColor(specimen['similarity'] ?? 0)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${specimen['similarity'] ?? 0}% similar',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: _getSimilarityColor(
                                specimen['similarity'] ?? 0),
                          ),
                        ),
                      ),
                      const Spacer(),
                      CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        size: 16,
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSimilarityColor(int similarity) {
    if (similarity >= 80) {
      return AppTheme.getSuccessColor(true);
    } else if (similarity >= 60) {
      return AppTheme.getWarningColor(true);
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  List<Map<String, dynamic>> _getRelatedSpecimens() {
    return [
      {
        'id': 'specimen_001',
        'name': 'Basalt Formation',
        'scientificName': 'Basaltica oceanus',
        'image':
            'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=400&h=300&fit=crop',
        'similarity': 92,
        'category': 'Igneous Rock',
      },
      {
        'id': 'specimen_002',
        'name': 'Olivine Crystal',
        'scientificName': 'Olivinus crystallus',
        'image':
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        'similarity': 87,
        'category': 'Mineral',
      },
      {
        'id': 'specimen_003',
        'name': 'Volcanic Glass',
        'scientificName': 'Obsidianus marinus',
        'image':
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop',
        'similarity': 78,
        'category': 'Volcanic Rock',
      },
      {
        'id': 'specimen_004',
        'name': 'Pumice Stone',
        'scientificName': 'Pumicus vesicularis',
        'image':
            'https://images.unsplash.com/photo-1509909756405-be0199881695?w=400&h=300&fit=crop',
        'similarity': 65,
        'category': 'Volcanic Rock',
      },
      {
        'id': 'specimen_005',
        'name': 'Marine Sediment',
        'scientificName': 'Sedimentum oceanicus',
        'image':
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop',
        'similarity': 58,
        'category': 'Sedimentary',
      },
    ];
  }
}
