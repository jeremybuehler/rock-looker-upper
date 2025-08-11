import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/ai_analysis_card.dart';
import './widgets/bottom_action_bar.dart';
import './widgets/compare_mode_tab.dart';
import './widgets/manual_search_tab.dart';
import './widgets/specimen_photo_viewer.dart';

class SpecimenIdentification extends StatefulWidget {
  const SpecimenIdentification({super.key});

  @override
  State<SpecimenIdentification> createState() => _SpecimenIdentificationState();
}

class _SpecimenIdentificationState extends State<SpecimenIdentification>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isAnalyzing = false;
  String? _specimenImageUrl;
  List<Map<String, dynamic>> _aiResults = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _comparisonCandidates = [];
  Map<String, dynamic>? _selectedIdentification;

  // Mock data for AI analysis results
  final List<Map<String, dynamic>> _mockAiResults = [
    {
      "id": 1,
      "scientificName": "Quartz var. Smoky",
      "commonName": "Smoky Quartz",
      "category": "Igneous",
      "confidence": 0.94,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=300&h=300&fit=crop",
      "imageUrl":
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=800&h=600&fit=crop",
      "formation": "Hydrothermal",
      "period": "Precambrian to Recent",
      "location": "Worldwide",
      "description":
          "A variety of quartz with gray to black coloration caused by natural radiation exposure.",
    },
    {
      "id": 2,
      "scientificName": "Feldspar var. Orthoclase",
      "commonName": "Orthoclase Feldspar",
      "category": "Igneous",
      "confidence": 0.87,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=300&h=300&fit=crop",
      "imageUrl":
          "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&h=600&fit=crop",
      "formation": "Plutonic",
      "period": "Precambrian to Recent",
      "location": "Continental Crust",
      "description":
          "A potassium-rich feldspar mineral commonly found in granite and other igneous rocks.",
    },
    {
      "id": 3,
      "scientificName": "Biotite Mica",
      "commonName": "Black Mica",
      "category": "Metamorphic",
      "confidence": 0.73,
      "thumbnailUrl":
          "https://images.unsplash.com/photo-1509909756405-be0199881695?w=300&h=300&fit=crop",
      "imageUrl":
          "https://images.unsplash.com/photo-1509909756405-be0199881695?w=800&h=600&fit=crop",
      "formation": "Metamorphic",
      "period": "Precambrian to Recent",
      "location": "Metamorphic Terranes",
      "description":
          "A dark-colored phyllosilicate mineral with perfect cleavage and metallic luster.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeWithMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeWithMockData() {
    // Simulate having a specimen image from camera capture
    setState(() {
      _specimenImageUrl =
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=600&h=600&fit=crop";
      _aiResults = _mockAiResults;
      _comparisonCandidates = _mockAiResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Specimen Identification'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _refreshAnalysis,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Refresh Analysis',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'retake_photo',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'camera_alt',
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Retake Photo'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'view_history',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'history',
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('View History'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'help_outline',
                      color: colorScheme.onSurface,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Text('Help & Tips'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAnalysis,
        child: Column(
          children: [
            // Specimen photo viewer
            SpecimenPhotoViewer(
              imageUrl: _specimenImageUrl,
              onRetakePhoto: _retakePhoto,
            ),

            // Tab bar
            Container(
              color: colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'psychology',
                      color: _tabController.index == 0
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    text: 'AI Results',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'search',
                      color: _tabController.index == 1
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    text: 'Manual Search',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'compare',
                      color: _tabController.index == 2
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    text: 'Compare',
                  ),
                ],
                labelColor: colorScheme.primary,
                unselectedLabelColor:
                    colorScheme.onSurface.withValues(alpha: 0.6),
                indicatorColor: colorScheme.primary,
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // AI Results tab
                  _buildAiResultsTab(),

                  // Manual Search tab
                  ManualSearchTab(
                    onSearch: _performManualSearch,
                    onFiltersChanged: _applyFilters,
                  ),

                  // Compare tab
                  CompareModeTab(
                    specimenImageUrl: _specimenImageUrl,
                    comparisonCandidates: _comparisonCandidates,
                    onCandidateSelected: _selectCandidate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        onSaveIdentification: _saveIdentification,
        onAddToCollection: _addToCollection,
        onShareResults: _shareResults,
        isIdentificationAvailable:
            _selectedIdentification != null || _aiResults.isNotEmpty,
      ),
    );
  }

  Widget _buildAiResultsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isAnalyzing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Analyzing specimen...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'This may take a few moments',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (_aiResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'psychology',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No AI analysis results available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Take a photo of your specimen to start analysis',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: _retakePhoto,
              icon: CustomIconWidget(
                iconName: 'camera_alt',
                color: colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Take Photo'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      itemCount: _aiResults.length,
      itemBuilder: (context, index) {
        final result = _aiResults[index];
        return GestureDetector(
          onLongPress: () => _showResultActions(context, result),
          child: AiAnalysisCard(
            analysisResult: result,
            onViewDetails: () => _viewResultDetails(result),
          ),
        );
      },
    );
  }

  Future<void> _refreshAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAnalyzing = false;
      _aiResults = _mockAiResults;
      _comparisonCandidates = _mockAiResults;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis updated with latest algorithms'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _performManualSearch(String query) {
    // Simulate manual search
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // Filter mock results based on query
    final filteredResults = _mockAiResults.where((result) {
      final scientificName = (result['scientificName'] as String).toLowerCase();
      final commonName = (result['commonName'] as String).toLowerCase();
      final category = (result['category'] as String).toLowerCase();
      final searchQuery = query.toLowerCase();

      return scientificName.contains(searchQuery) ||
          commonName.contains(searchQuery) ||
          category.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = filteredResults;
    });
  }

  void _applyFilters(Map<String, String> filters) {
    // Apply filters to search results
    List<Map<String, dynamic>> filteredResults = List.from(_mockAiResults);

    if (filters.containsKey('Rock Type')) {
      filteredResults = filteredResults.where((result) {
        return (result['category'] as String)
            .toLowerCase()
            .contains(filters['Rock Type']!.toLowerCase());
      }).toList();
    }

    // Add more filter logic as needed

    setState(() {
      _searchResults = filteredResults;
    });
  }

  void _selectCandidate(Map<String, dynamic> candidate) {
    setState(() {
      _selectedIdentification = candidate;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${candidate['scientificName']}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Details',
          onPressed: () => _viewResultDetails(candidate),
        ),
      ),
    );
  }

  void _viewResultDetails(Map<String, dynamic> result) {
    Navigator.pushNamed(
      context,
      '/symbol-detail-view',
      arguments: result,
    );
  }

  void _showResultActions(BuildContext context, Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'favorite_border',
                  color: colorScheme.primary,
                  size: 24,
                ),
                title: Text('Mark as Favorite'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsFavorite(result);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'report_problem',
                  color: colorScheme.error,
                  size: 24,
                ),
                title: Text('Report Error'),
                onTap: () {
                  Navigator.pop(context);
                  _reportError(result);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'similarity',
                  color: colorScheme.secondary,
                  size: 24,
                ),
                title: Text('Find Similar Specimens'),
                onTap: () {
                  Navigator.pop(context);
                  _findSimilarSpecimens(result);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _markAsFavorite(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${result['scientificName']} to favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reportError(Map<String, dynamic> result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error report submitted for ${result['scientificName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _findSimilarSpecimens(Map<String, dynamic> result) {
    Navigator.pushNamed(
      context,
      '/database-browser',
      arguments: {'category': result['category']},
    );
  }

  void _retakePhoto() {
    Navigator.pushNamed(context, '/camera-capture');
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'retake_photo':
        _retakePhoto();
        break;
      case 'view_history':
        Navigator.pushNamed(context, '/collection-manager');
        break;
      case 'help':
        _showHelpDialog();
        break;
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Identification Tips'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Ensure good lighting when taking photos'),
              Text('• Include a scale reference if possible'),
              Text('• Take multiple angles for better analysis'),
              Text('• Clean the specimen surface before photographing'),
              Text('• Use the compare mode to verify matches'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  void _saveIdentification() {
    final identification = _selectedIdentification ??
        (_aiResults.isNotEmpty ? _aiResults.first : null);

    if (identification != null) {
      // Save identification with timestamp and location
      final savedData = {
        ...identification,
        'timestamp': DateTime.now().toIso8601String(),
        'location': 'Current GPS Location', // Would be actual GPS data
        'confidence_level': 'High',
        'verified': false,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Identification saved: ${identification['scientificName']}'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => Navigator.pushNamed(context, '/field-notes'),
          ),
        ),
      );
    }
  }

  void _addToCollection() {
    final identification = _selectedIdentification ??
        (_aiResults.isNotEmpty ? _aiResults.first : null);

    if (identification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Added to collection: ${identification['scientificName']}'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Collection',
            onPressed: () =>
                Navigator.pushNamed(context, '/collection-manager'),
          ),
        ),
      );
    }
  }

  void _shareResults() {
    final identification = _selectedIdentification ??
        (_aiResults.isNotEmpty ? _aiResults.first : null);

    if (identification != null) {
      // Simulate sharing functionality
      final shareText = '''
Specimen Identification Results:

Scientific Name: ${identification['scientificName']}
Common Name: ${identification['commonName']}
Category: ${identification['category']}
Confidence: ${((identification['confidence'] as double) * 100).toStringAsFixed(0)}%

Identified using RockScope Analyzer
Date: ${DateTime.now().toString().split(' ')[0]}
      ''';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Results shared successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
