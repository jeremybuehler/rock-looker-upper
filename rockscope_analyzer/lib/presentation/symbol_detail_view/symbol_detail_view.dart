import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/related_specimens_section.dart';
import './widgets/symbol_action_bar.dart';
import './widgets/symbol_image_gallery.dart';
import './widgets/symbol_info_tabs.dart';

class SymbolDetailView extends StatefulWidget {
  const SymbolDetailView({super.key});

  @override
  State<SymbolDetailView> createState() => _SymbolDetailViewState();
}

class _SymbolDetailViewState extends State<SymbolDetailView> {
  bool _isBookmarked = false;
  late Map<String, dynamic> _symbolData;
  late ScrollController _scrollController;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _initializeSymbolData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 200;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  void _initializeSymbolData() {
    _symbolData = {
      'id': 'specimen_marine_001',
      'name': 'Pillow Basalt Formation',
      'scientificName': 'Basaltica pillow oceanicus',
      'commonNames': ['Ocean Floor Basalt', 'Submarine Basalt', 'Pillow Lava'],
      'kingdom': 'Mineral',
      'phylum': 'Igneous',
      'class': 'Mafic',
      'order': 'Volcanic',
      'description':
          '''Pillow basalts are volcanic rocks that form when basaltic lava erupts underwater or flows into water. The rapid cooling of the lava by the surrounding water causes the formation of distinctive pillow-shaped structures. These formations are commonly found on ocean floors and are important indicators of ancient marine environments. The characteristic rounded, bulbous shapes result from the lava's viscosity and the quenching effect of seawater, creating a glassy outer rim while maintaining a crystalline interior.''',
      'sizeRange': '0.5m - 3m diameter',
      'habitat': 'Ocean floor, mid-ocean ridges',
      'rarity': 'Common in marine environments',
      'conservationStatus': 'Stable',
      'images': [
        'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1509909756405-be0199881695?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800&h=600&fit=crop',
      ],
      'properties': {
        'primaryElements': 'Silicon, Aluminum, Iron, Magnesium',
        'chemicalFormula': '(Ca,Na)(Mg,Fe,Al,Ti)(Si,Al)₂O₆',
        'molecularWeight': '272.63 g/mol',
        'hardness': '5-6 (Mohs scale)',
        'density': '2.8-3.0 g/cm³',
        'crystalSystem': 'Monoclinic to Triclinic',
        'luster': 'Vitreous to dull',
        'color': 'Dark gray to black',
        'streak': 'Gray to black',
        'cleavage': 'Poor to absent',
        'fracture': 'Conchoidal to uneven',
        'transparency': 'Opaque',
        'fluorescence': 'None',
      },
      'formation': {
        'process': 'Underwater volcanic eruption and rapid cooling',
        'environment': 'Mid-ocean ridges, submarine volcanic zones',
        'temperature': '1000-1200°C (initial), rapid cooling to <100°C',
        'pressure': 'High hydrostatic pressure (deep ocean)',
        'timePeriods': [
          {'period': 'Archean', 'years': '4.0-2.5 billion years ago'},
          {
            'period': 'Proterozoic',
            'years': '2.5 billion-541 million years ago'
          },
          {'period': 'Phanerozoic', 'years': '541 million years ago-present'},
        ],
        'associatedMinerals': [
          'Plagioclase',
          'Pyroxene',
          'Olivine',
          'Magnetite',
          'Chlorite'
        ],
      },
      'locations': [
        {
          'name': 'Mid-Atlantic Ridge',
          'description':
              'Active spreading center with extensive pillow basalt formations',
          'coordinates': '0°N, 30°W',
        },
        {
          'name': 'East Pacific Rise',
          'description':
              'Fast-spreading ridge system with young pillow basalts',
          'coordinates': '10°S, 105°W',
        },
        {
          'name': 'Juan de Fuca Ridge',
          'description':
              'Well-studied pillow basalt formations off Pacific Northwest',
          'coordinates': '46°N, 130°W',
        },
        {
          'name': 'Troodos Ophiolite, Cyprus',
          'description': 'Ancient pillow basalts now exposed on land',
          'coordinates': '35°N, 33°E',
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 2.h),
                _buildImageGallery(),
                SizedBox(height: 3.h),
                _buildInfoTabs(),
                _buildRelatedSpecimens(),
                SizedBox(height: 10.h), // Space for action bar
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildBookmarkButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
      elevation: _showAppBarTitle ? 2 : 0,
      leading: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            size: 24,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          _symbolData['name'] ?? 'Specimen Detail',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/camera-capture');
            },
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            _symbolData['name'] ?? 'Unknown Specimen',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.onSurface,
              height: 1.2,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _symbolData['scientificName'] ?? 'Scientific name unknown',
            style: TextStyle(
              fontSize: 16.sp,
              fontStyle: FontStyle.italic,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _buildInfoChip(
                icon: 'category',
                label: _symbolData['class'] ?? 'Unknown',
                color: AppTheme.lightTheme.primaryColor,
              ),
              _buildInfoChip(
                icon: 'location_on',
                label: _symbolData['habitat'] ?? 'Various',
                color: AppTheme.getSuccessColor(true),
              ),
              _buildInfoChip(
                icon: 'star',
                label: _symbolData['rarity'] ?? 'Unknown',
                color: AppTheme.getWarningColor(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            size: 16,
            color: color,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return SymbolImageGallery(
      images: ((_symbolData['images'] as List?) ?? []).cast<String>(),
      heroTag: 'specimen_${_symbolData['id']}',
    );
  }

  Widget _buildInfoTabs() {
    return Container(
      height: 50.h,
      child: SymbolInfoTabs(
        symbolData: _symbolData,
      ),
    );
  }

  Widget _buildRelatedSpecimens() {
    return RelatedSpecimensSection(
      currentSpecimenId: _symbolData['id'] ?? '',
    );
  }

  Widget _buildBookmarkButton() {
    return Container(
      margin: EdgeInsets.only(top: 12.h, right: 2.w),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _isBookmarked = !_isBookmarked;
          });
          _showBookmarkFeedback();
        },
        backgroundColor: _isBookmarked
            ? AppTheme.getWarningColor(true)
            : AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: _isBookmarked
            ? Colors.white
            : AppTheme.lightTheme.colorScheme.onSurface,
        elevation: 4,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: CustomIconWidget(
            key: ValueKey(_isBookmarked),
            iconName: _isBookmarked ? 'bookmark' : 'bookmark_border',
            size: 24,
            color: _isBookmarked
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return SymbolActionBar(
      symbolData: _symbolData,
      onAddToCollection: () {
        // Handle add to collection
      },
      onCompareSimilar: () {
        // Handle compare similar
      },
      onShare: () {
        // Handle share
      },
      onFieldNotes: () {
        // Handle field notes
      },
    );
  }

  void _showBookmarkFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: _isBookmarked ? 'bookmark' : 'bookmark_border',
              size: 20,
              color: Colors.white,
            ),
            SizedBox(width: 2.w),
            Text(
              _isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        backgroundColor: _isBookmarked
            ? AppTheme.getSuccessColor(true)
            : AppTheme.lightTheme.colorScheme.onSurface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
