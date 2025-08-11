import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../providers/specimen_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../../widgets/touch_optimized_widgets.dart';
import './widgets/collection_stats_card.dart';
import './widgets/export_options_sheet.dart';
import './widgets/filter_segment_control.dart';
import './widgets/search_sort_bar.dart';
import './widgets/sort_options_sheet.dart';
import './widgets/specimen_card.dart';

class CollectionManager extends ConsumerStatefulWidget {
  const CollectionManager({super.key});

  @override
  ConsumerState<CollectionManager> createState() => _CollectionManagerState();
}

class _CollectionManagerState extends ConsumerState<CollectionManager> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int _selectedFilterIndex = 0;
  bool _isMapView = false;

  final List<String> _filterSegments = [
    'All Specimens',
    'Recent',
    'Favorites',
    'Unverified',
  ];

  // Mock data removed - now using Riverpod providers

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
    });
    ref.read(multiSelectModeProvider.notifier).state = false;
    ref.read(selectedSpecimensProvider.notifier).state = {};
  }

  void _onSortChanged(String sortOption) {
    final sortEnum = _mapStringToSortOption(sortOption);
    ref.read(sortOptionProvider.notifier).state = sortEnum;
  }

  void _onSortOrderChanged(bool isAscending) {
    // Note: The existing provider doesn't handle sort order, 
    // so we'll handle it locally for now
  }

  SortOption _mapStringToSortOption(String sortString) {
    switch (sortString) {
      case 'date':
        return SortOption.dateAdded;
      case 'confidence':
        return SortOption.confidence;
      case 'name':
        return SortOption.alphabetical;
      case 'location':
        return SortOption.category; // Map location to category for now
      default:
        return SortOption.dateAdded;
    }
  }

  void _toggleMapView() {
    setState(() {
      _isMapView = !_isMapView;
    });
  }

  void _onSpecimenTap(Map<String, dynamic> specimen) {
    final isMultiSelectMode = ref.read(multiSelectModeProvider);
    if (isMultiSelectMode) {
      _toggleSpecimenSelection(specimen['id'] as int);
    } else {
      Navigator.pushNamed(context, '/specimen-identification');
    }
  }

  void _toggleSpecimenSelection(int specimenId) {
    final selectedSpecimens = ref.read(selectedSpecimensProvider);
    final specimenIdStr = specimenId.toString();
    
    if (selectedSpecimens.contains(specimenIdStr)) {
      ref.read(selectedSpecimensProvider.notifier).state = 
          selectedSpecimens.where((id) => id != specimenIdStr).toSet();
      
      if (ref.read(selectedSpecimensProvider).isEmpty) {
        ref.read(multiSelectModeProvider.notifier).state = false;
      }
    } else {
      ref.read(selectedSpecimensProvider.notifier).state = 
          {...selectedSpecimens, specimenIdStr};
    }
  }

  void _onSpecimenLongPress(int specimenId) {
    ref.read(multiSelectModeProvider.notifier).state = true;
    ref.read(selectedSpecimensProvider.notifier).state = 
        {...ref.read(selectedSpecimensProvider), specimenId.toString()};
  }

  Future<void> _onRefresh() async {
    try {
      // Refresh collection from provider
      await ref.read(collectionProvider.notifier).refresh();
      
      ref.read(snackbarProvider.notifier).showSuccess('Collection refreshed');
    } catch (e) {
      ref.read(snackbarProvider.notifier).showError('Failed to refresh collection');
    }
  }

  void _showSortOptions() {
    final currentSort = ref.read(sortOptionProvider);
    final currentSortString = _mapSortOptionToString(currentSort);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortOptionsSheet(
        currentSortOption: currentSortString,
        isAscending: false, // Default for now
        onSortChanged: _onSortChanged,
        onOrderChanged: _onSortOrderChanged,
      ),
    );
  }

  String _mapSortOptionToString(SortOption option) {
    switch (option) {
      case SortOption.dateAdded:
        return 'date';
      case SortOption.confidence:
        return 'confidence';
      case SortOption.alphabetical:
        return 'name';
      case SortOption.category:
        return 'location'; // Map back for compatibility
    }
  }

  void _showExportOptions() {
    final selectedSpecimenIds = ref.read(selectedSpecimensProvider);
    final collection = ref.read(sortedCollectionProvider);
    
    // Convert SpecimenModel to Map for compatibility with existing export logic
    final selectedSpecimenData = collection
        .where((specimen) => selectedSpecimenIds.contains(specimen.id.toString()))
        .map((specimen) => {
          'id': specimen.id,
          'name': specimen.name,
          'confidence': specimen.confidence,
          'location': specimen.location,
          'date': specimen.date,
          'status': specimen.status,
          'geologicalPeriod': specimen.geologicalPeriod,
          'formation': specimen.formation,
          'isFavorite': specimen.isFavorite,
        })
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportOptionsSheet(
        selectedSpecimens: selectedSpecimenData,
        onExportCSV: () => _exportToCSV(selectedSpecimenData),
        onExportPDF: () => _exportToPDF(selectedSpecimenData),
        onExportDatabase: () => _exportToDatabase(selectedSpecimenData),
      ),
    );
  }

  Future<void> _exportToCSV(List<Map<String, dynamic>> specimens) async {
    final csvContent = _generateCSVContent(specimens);
    await _downloadFile(csvContent,
        'rockscope_collection_${DateTime.now().millisecondsSinceEpoch}.csv');
    _showExportSuccess('CSV');
  }

  Future<void> _exportToPDF(List<Map<String, dynamic>> specimens) async {
    final pdfContent = _generatePDFContent(specimens);
    await _downloadFile(pdfContent,
        'rockscope_report_${DateTime.now().millisecondsSinceEpoch}.txt');
    _showExportSuccess('PDF Report');
  }

  Future<void> _exportToDatabase(List<Map<String, dynamic>> specimens) async {
    final jsonContent = _generateDatabaseContent(specimens);
    await _downloadFile(jsonContent,
        'rockscope_database_${DateTime.now().millisecondsSinceEpoch}.json');
    _showExportSuccess('Database Export');
  }

  String _generateCSVContent(List<Map<String, dynamic>> specimens) {
    final headers = [
      'ID',
      'Name',
      'Confidence',
      'Status',
      'Location',
      'Date',
      'Geological Period',
      'Formation'
    ];
    final csvRows = <String>[];

    csvRows.add(headers.join(','));

    for (final specimen in specimens) {
      final row = [
        specimen['id'].toString(),
        '"${specimen['name']}"',
        specimen['confidence'].toString(),
        specimen['status'],
        '"${specimen['location']}"',
        specimen['date'],
        specimen['geologicalPeriod'],
        specimen['formation'],
      ];
      csvRows.add(row.join(','));
    }

    return csvRows.join('\n');
  }

  String _generatePDFContent(List<Map<String, dynamic>> specimens) {
    final buffer = StringBuffer();
    buffer.writeln('ROCKSCOPE ANALYZER - COLLECTION REPORT');
    buffer.writeln('Generated: ${DateTime.now().toString()}');
    buffer.writeln('Total Specimens: ${specimens.length}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    for (final specimen in specimens) {
      buffer.writeln('SPECIMEN ID: ${specimen['id']}');
      buffer.writeln('Name: ${specimen['name']}');
      buffer.writeln('Confidence: ${specimen['confidence']}%');
      buffer.writeln('Status: ${specimen['status']}');
      buffer.writeln('Location: ${specimen['location']}');
      buffer.writeln('Date Discovered: ${specimen['date']}');
      buffer.writeln('Geological Period: ${specimen['geologicalPeriod']}');
      buffer.writeln('Formation: ${specimen['formation']}');
      buffer.writeln('-' * 30);
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _generateDatabaseContent(List<Map<String, dynamic>> specimens) {
    final exportData = {
      'export_metadata': {
        'application': 'RockScope Analyzer',
        'version': '1.0.0',
        'export_date': DateTime.now().toIso8601String(),
        'total_specimens': specimens.length,
      },
      'specimens': specimens,
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  Future<void> _downloadFile(String content, String filename) async {
    try {
      if (kIsWeb) {
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
      }
    } catch (e) {
      _showExportError();
    }
  }

  void _showExportSuccess(String format) {
    ref.read(snackbarProvider.notifier).showSuccess('$format exported successfully');
    
    ref.read(multiSelectModeProvider.notifier).state = false;
    ref.read(selectedSpecimensProvider.notifier).state = {};
  }

  void _showExportError() {
    ref.read(snackbarProvider.notifier).showError('Export failed. Please try again.');
  }

  // Stats now come from providers

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collection = ref.watch(sortedCollectionProvider);
    final filteredCollection = _applyFilterToCollection(collection);
    final multiSelectMode = ref.watch(multiSelectModeProvider);
    final selectedSpecimens = ref.watch(selectedSpecimensProvider);
    final collectionStats = ref.watch(collectionStatsProvider);
    
    // Listen to snackbar state changes
    ref.listen<SnackbarState?>(snackbarProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: _getSnackbarColor(next.type, theme),
            behavior: SnackBarBehavior.floating,
            duration: next.duration,
            action: next.action,
          ),
        );
        // Clear snackbar after showing
        Future.microtask(() => ref.read(snackbarProvider.notifier).hide());
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          multiSelectMode
              ? '${selectedSpecimens.length} Selected'
              : 'Collection Manager',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        leading: multiSelectMode
            ? IconButton(
                onPressed: () {
                  ref.read(multiSelectModeProvider.notifier).state = false;
                  ref.read(selectedSpecimensProvider.notifier).state = {};
                },
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
        actions: multiSelectMode
            ? [
                IconButton(
                  onPressed:
                      selectedSpecimens.isNotEmpty ? _showExportOptions : null,
                  icon: CustomIconWidget(
                    iconName: 'file_download',
                    color: selectedSpecimens.isNotEmpty
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ),
              ]
            : [
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/camera-capture'),
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            CollectionStatsCard(
              totalSpecimens: collectionStats.totalSpecimens,
              averageAccuracy: collectionStats.averageConfidence,
              geographicCoverage: collectionStats.categoryCounts.length,
            ),
            FilterSegmentControl(
              selectedIndex: _selectedFilterIndex,
              onSelectionChanged: _onFilterChanged,
              segments: _filterSegments,
            ),
            SearchSortBar(
              searchController: _searchController,
              onSearchChanged: (_) => _onSearchChanged(),
              onSortPressed: _showSortOptions,
              onMapToggle: _toggleMapView,
              isMapView: _isMapView,
            ),
            Expanded(
              child: _isMapView ? _buildMapView() : _buildListView(filteredCollection, multiSelectMode, selectedSpecimens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<dynamic> specimens, bool multiSelectMode, Set<String> selectedSpecimens) {
    if (specimens.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 2.h),
      itemCount: specimens.length,
      itemBuilder: (context, index) {
        final specimen = specimens[index];
        Map<String, dynamic> specimenData;
        String specimenId;
        
        // Handle both SpecimenModel and Map data
        if (specimen is Map<String, dynamic>) {
          specimenData = specimen;
          specimenId = specimen['id'].toString();
        } else {
          // Convert SpecimenModel to Map for compatibility
          specimenData = {
            'id': specimen.id,
            'name': specimen.name,
            'confidence': specimen.confidence,
            'location': specimen.location,
            'date': specimen.date,
            'status': specimen.status,
            'geologicalPeriod': specimen.geologicalPeriod,
            'formation': specimen.formation,
            'isFavorite': specimen.isFavorite,
          };
          specimenId = specimen.id.toString();
        }

        return SpecimenCard(
          specimen: specimenData,
          isSelected: selectedSpecimens.contains(specimenId),
          onTap: () => _onSpecimenTap(specimenData),
          onSelectionChanged: multiSelectMode
              ? (selected) => _toggleSpecimenSelection(int.tryParse(specimenId) ?? 0)
              : (selected) => _onSpecimenLongPress(int.tryParse(specimenId) ?? 0),
          onEdit: () =>
              Navigator.pushNamed(context, '/specimen-identification'),
          onAddNotes: () => Navigator.pushNamed(context, '/field-notes'),
          onViewLocation: () =>
              Navigator.pushNamed(context, '/database-browser'),
          onRemove: () => _removeSpecimen(int.tryParse(specimenId) ?? 0),
          onShare: () => _shareSpecimen(specimenData),
        );
      },
    );
  }

  Widget _buildMapView() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'map',
            color: theme.colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Map View',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Interactive map showing specimen locations\nwith clustering for dense areas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => _toggleMapView(),
            child: const Text('Switch to List View'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'folder_open',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Specimens Found',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Start capturing specimens to build your collection',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/camera-capture'),
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            label: const Text('Capture Specimen'),
          ),
        ],
      ),
    );
  }

  void _removeSpecimen(int specimenId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Specimen'),
        content: const Text(
            'Are you sure you want to remove this specimen from your collection?'),
        actions: [
          TouchOptimizedButton(
            onPressed: () => Navigator.pop(context),
            type: TouchButtonType.text,
            child: const Text('Cancel'),
          ),
          TouchOptimizedButton(
            onPressed: () async {
              try {
                await ref.read(collectionProvider.notifier)
                    .removeSpecimen(specimenId.toString());
                
                final selectedSpecimens = ref.read(selectedSpecimensProvider);
                if (selectedSpecimens.contains(specimenId.toString())) {
                  ref.read(selectedSpecimensProvider.notifier).state = 
                      selectedSpecimens.where((id) => id != specimenId.toString()).toSet();
                }
                
                Navigator.pop(context);
                ref.read(snackbarProvider.notifier)
                    .showSuccess('Specimen removed from collection');
              } catch (e) {
                Navigator.pop(context);
                ref.read(snackbarProvider.notifier)
                    .showError('Failed to remove specimen');
              }
            },
            type: TouchButtonType.text,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.error,
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _shareSpecimen(Map<String, dynamic> specimen) {
    final _ = '''
RockScope Analysis Result

Specimen: ${specimen['name']}
Confidence: ${specimen['confidence']}%
Location: ${specimen['location']}
Date: ${specimen['date']}
Status: ${specimen['status']}

Generated by RockScope Analyzer
''';

    ref.read(snackbarProvider.notifier).showSnackbar(
      message: 'Sharing: ${specimen['name']}',
      action: SnackBarAction(
        label: 'Copy',
        onPressed: () {
          // In a real app, this would copy to clipboard
        },
      ),
    );
  }

  // Helper method to apply filter to collection
  List<dynamic> _applyFilterToCollection(List<dynamic> collection) {
    List<dynamic> filtered = collection;
    
    // Apply segment filter
    switch (_selectedFilterIndex) {
      case 1: // Recent - specimens added in last 3 days
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        filtered = collection.where((specimen) {
          if (specimen is Map<String, dynamic>) {
            final dateStr = specimen['date'] as String?;
            if (dateStr == null) return false;
            try {
              final date = DateTime.parse(dateStr);
              return date.isAfter(threeDaysAgo);
            } catch (e) {
              return false;
            }
          } else {
            try {
              final date = DateTime.parse(specimen.date);
              return date.isAfter(threeDaysAgo);
            } catch (e) {
              return false;
            }
          }
        }).toList();
        break;
      case 2: // Favorites
        filtered = collection.where((specimen) {
          if (specimen is Map<String, dynamic>) {
            return specimen['isFavorite'] as bool? ?? false;
          } else {
            return false; // SpecimenModel doesn't have favorite flag yet
          }
        }).toList();
        break;
      case 3: // Unverified - low confidence specimens
        filtered = collection.where((specimen) {
          if (specimen is Map<String, dynamic>) {
            final status = specimen['status'] as String?;
            return status == 'uncertain';
          } else {
            return specimen.status == 'uncertain' || specimen.confidence < 70;
          }
        }).toList();
        break;
      default: // All Specimens
        break;
    }
    
    return filtered;
  }

  Color _getSnackbarColor(SnackbarType type, ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return AppTheme.getSuccessColor(theme.brightness == Brightness.dark);
      case SnackbarType.error:
        return theme.colorScheme.error;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.info:
        return theme.colorScheme.primary;
    }
  }
}
