import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SymbolInfoTabs extends StatefulWidget {
  final Map<String, dynamic> symbolData;

  const SymbolInfoTabs({
    super.key,
    required this.symbolData,
  });

  @override
  State<SymbolInfoTabs> createState() => _SymbolInfoTabsState();
}

class _SymbolInfoTabsState extends State<SymbolInfoTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.lightTheme.primaryColor,
            unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
            indicatorColor: AppTheme.lightTheme.primaryColor,
            indicatorWeight: 2,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Properties'),
              Tab(text: 'Formation'),
              Tab(text: 'Locations'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildPropertiesTab(),
              _buildFormationTab(),
              _buildLocationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Scientific Classification',
            children: [
              _buildInfoRow('Scientific Name',
                  widget.symbolData['scientificName'] ?? 'Unknown'),
              _buildInfoRow(
                  'Common Names',
                  (widget.symbolData['commonNames'] as List?)?.join(', ') ??
                      'N/A'),
              _buildInfoRow(
                  'Kingdom', widget.symbolData['kingdom'] ?? 'Unknown'),
              _buildInfoRow('Phylum', widget.symbolData['phylum'] ?? 'Unknown'),
              _buildInfoRow('Class', widget.symbolData['class'] ?? 'Unknown'),
              _buildInfoRow('Order', widget.symbolData['order'] ?? 'Unknown'),
            ],
          ),
          SizedBox(height: 3.h),
          _buildInfoCard(
            title: 'Description',
            children: [
              Text(
                widget.symbolData['description'] ?? 'No description available.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildInfoCard(
            title: 'Quick Facts',
            children: [
              _buildInfoRow(
                  'Size Range', widget.symbolData['sizeRange'] ?? 'Variable'),
              _buildInfoRow(
                  'Habitat', widget.symbolData['habitat'] ?? 'Various'),
              _buildInfoRow('Rarity', widget.symbolData['rarity'] ?? 'Common'),
              _buildInfoRow('Conservation Status',
                  widget.symbolData['conservationStatus'] ?? 'Not Evaluated'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab() {
    final properties =
        widget.symbolData['properties'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          _buildExpandableCard(
            title: 'Chemical Composition',
            icon: 'science',
            children: [
              _buildInfoRow('Primary Elements',
                  properties['primaryElements'] ?? 'Unknown'),
              _buildInfoRow(
                  'Chemical Formula', properties['chemicalFormula'] ?? 'N/A'),
              _buildInfoRow(
                  'Molecular Weight', properties['molecularWeight'] ?? 'N/A'),
            ],
          ),
          SizedBox(height: 2.h),
          _buildExpandableCard(
            title: 'Physical Properties',
            icon: 'straighten',
            children: [
              _buildInfoRow(
                  'Hardness (Mohs)', properties['hardness'] ?? 'Unknown'),
              _buildInfoRow('Density', properties['density'] ?? 'Unknown'),
              _buildInfoRow(
                  'Crystal System', properties['crystalSystem'] ?? 'Unknown'),
              _buildInfoRow('Luster', properties['luster'] ?? 'Unknown'),
              _buildInfoRow('Color', properties['color'] ?? 'Variable'),
              _buildInfoRow('Streak', properties['streak'] ?? 'Unknown'),
            ],
          ),
          SizedBox(height: 2.h),
          _buildExpandableCard(
            title: 'Identifying Characteristics',
            icon: 'visibility',
            children: [
              _buildInfoRow('Cleavage', properties['cleavage'] ?? 'Unknown'),
              _buildInfoRow('Fracture', properties['fracture'] ?? 'Unknown'),
              _buildInfoRow(
                  'Transparency', properties['transparency'] ?? 'Unknown'),
              _buildInfoRow(
                  'Fluorescence', properties['fluorescence'] ?? 'None'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormationTab() {
    final formation =
        widget.symbolData['formation'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Geological Formation',
            children: [
              _buildInfoRow(
                  'Formation Process', formation['process'] ?? 'Unknown'),
              _buildInfoRow('Formation Environment',
                  formation['environment'] ?? 'Various'),
              _buildInfoRow(
                  'Temperature Range', formation['temperature'] ?? 'Variable'),
              _buildInfoRow(
                  'Pressure Conditions', formation['pressure'] ?? 'Variable'),
            ],
          ),
          SizedBox(height: 3.h),
          _buildTimelineCard(),
          SizedBox(height: 3.h),
          _buildInfoCard(
            title: 'Associated Minerals',
            children: [
              Text(
                (formation['associatedMinerals'] as List?)?.join(', ') ??
                    'None specified',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsTab() {
    final locations = widget.symbolData['locations'] as List? ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 25.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'map',
                    size: 48,
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.6),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Interactive Map',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Formation sites and discovery regions',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Known Formation Sites',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...locations.map((location) =>
              _buildLocationCard(location as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ExpansionTile(
        leading: CustomIconWidget(
          iconName: icon,
          size: 24,
          color: AppTheme.lightTheme.primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    final formation =
        widget.symbolData['formation'] as Map<String, dynamic>? ?? {};
    final timePeriods = formation['timePeriods'] as List? ??
        [
          {
            'period': 'Precambrian',
            'years': '4.6 billion - 541 million years ago'
          },
          {'period': 'Paleozoic', 'years': '541 - 252 million years ago'},
          {'period': 'Mesozoic', 'years': '252 - 66 million years ago'},
          {'period': 'Cenozoic', 'years': '66 million years ago - present'},
        ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geological Timeline',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...timePeriods.map(
              (period) => _buildTimelinePeriod(period as Map<String, dynamic>)),
        ],
      ),
    );
  }

  Widget _buildTimelinePeriod(Map<String, dynamic> period) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period['period'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  period['years'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                size: 20,
                color: AppTheme.lightTheme.primaryColor,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  location['name'] ?? 'Unknown Location',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            location['description'] ?? 'No description available',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          if (location['coordinates'] != null) ...[
            SizedBox(height: 1.h),
            Text(
              'Coordinates: ${location['coordinates']}',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
