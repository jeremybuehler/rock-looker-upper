import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/collection_stats_card.dart';
import './widgets/export_options_sheet.dart';
import './widgets/filter_segment_control.dart';
import './widgets/search_sort_bar.dart';
import './widgets/sort_options_sheet.dart';
import './widgets/specimen_card.dart';

class CollectionManagerImproved extends StatefulWidget {
  const CollectionManagerImproved({super.key});

  @override
  State<CollectionManagerImproved> createState() => _CollectionManagerImprovedState();
}

class _CollectionManagerImprovedState extends State<CollectionManagerImproved> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RockDatabaseService _databaseService = RockDatabaseService();

  int _selectedFilterIndex = 0;
  String _currentSortOption = 'date';
  bool _isAscending = false;
  bool _isMapView = false;
  bool _isMultiSelectMode = false;
  Set<int> _selectedSpecimens = {};
  List<Map<String, dynamic>> _allSpecimens = [];
  List<Map<String, dynamic>> _filteredSpecimens = [];
  bool _isRefreshing = false;
  bool _isLoading = true;

  final List<String> _filterSegments = [
    'All Specimens',
    'Recent',
    'Favorites',
    'Unverified',
  ];

  @override
  void initState() {
    super.initState();
    _loadSpecimens();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSpecimens() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Generate a large collection with 25 specimens
        _allSpecimens = _databaseService.generateCollectionSpecimens(25);
        _filteredSpecimens = List.from(_allSpecimens);
        _isLoading = false;
      });
    });
  }

  void _onSearchChanged() {
    _filterSpecimens();
  }

  void _filterSpecimens() {
    setState(() {
      _filteredSpecimens = _allSpecimens.where((specimen) {
        // Apply search filter
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          final name = (specimen['name'] as String).toLowerCase();
          final location = (specimen['location'] as String).toLowerCase();
          final category = (specimen['category'] as String).toLowerCase();
          final formation = (specimen['formation'] as String).toLowerCase();

          if (!name.contains(searchQuery) &&
              !location.contains(searchQuery) &&
              !category.contains(searchQuery) &&
              !formation.contains(searchQuery)) {
            return false;
          }
        }

        // Apply segment filter
        switch (_selectedFilterIndex) {
          case 1: // Recent
            final date = specimen['date'] as String;
            return date.contains('Aug 8') ||
                date.contains('Aug 7') ||
                date.contains('Aug 6') ||
                date.contains('Aug 9') ||
                date.contains('Aug 10');
          case 2: // Favorites
            return specimen['isFavorite'] as bool;
          case 3: // Unverified
            return (specimen['status'] as String) == 'uncertain';
          default: // All Specimens
            return true;
        }
      }).toList();

      // Apply sorting
      _filteredSpecimens.sort((a, b) {
        int comparison = 0;

        switch (_currentSortOption) {
          case 'date':
            comparison = (a['date'] as String).compareTo(b['date'] as String);
            break;
          case 'confidence':
            comparison = (a['confidence'] as double)
                .compareTo(b['confidence'] as double);
            break;
          case 'name':
            comparison = (a['name'] as String).compareTo(b['name'] as String);
            break;
          case 'location':
            comparison =
                (a['location'] as String).compareTo(b['location'] as String);
            break;
        }

        return _isAscending ? comparison : -comparison;
      });
    });
  }

  void _onFilterChanged(int index) {
    setState(() {
      _selectedFilterIndex = index;
      _isMultiSelectMode = false;
      _selectedSpecimens.clear();
    });
    _filterSpecimens();
  }

  void _onSortChanged(String sortOption) {
    setState(() {
      _currentSortOption = sortOption;
    });
    _filterSpecimens();
  }

  void _onSortOrderChanged(bool isAscending) {
    setState(() {
      _isAscending = isAscending;
    });
    _filterSpecimens();
  }

  void _toggleMapView() {
    setState(() {
      _isMapView = !_isMapView;
    });
  }

  void _onSpecimenTap(Map<String, dynamic> specimen) {
    if (_isMultiSelectMode) {
      _toggleSpecimenSelection(specimen['id'] as int);
    } else {
      // Navigate to specimen detail with specimen data
      Navigator.pushNamed(
        context, 
        '/specimen-identification',
        arguments: specimen,
      );
    }
  }

  void _toggleSpecimenSelection(int specimenId) {
    setState(() {
      if (_selectedSpecimens.contains(specimenId)) {
        _selectedSpecimens.remove(specimenId);
        if (_selectedSpecimens.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedSpecimens.add(specimenId);
      }
    });
  }

  void _onSpecimenLongPress(int specimenId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedSpecimens.add(specimenId);
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate AI confidence score update
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      // Reload specimens with updated data
      _loadSpecimens();
      _isRefreshing = false;
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortOptionsSheet(
        currentSortOption: _currentSortOption,
        isAscending: _isAscending,
        onSortChanged: _onSortChanged,
        onOrderChanged: _onSortOrderChanged,
      ),
    );
  }

  void _showExportOptions() {
    final selectedSpecimenData = _filteredSpecimens
        .where((specimen) => _selectedSpecimens.contains(specimen['id']))
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
      'Category',
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
        specimen['category'] ?? 'Unknown',
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
      buffer.writeln('Category: ${specimen['category'] ?? 'Unknown'}');
      buffer.writeln('Confidence: ${specimen['confidence']}%');
      buffer.writeln('Status: ${specimen['status']}');
      buffer.writeln('Location: ${specimen['location']}');
      buffer.writeln('Date Discovered: ${specimen['date']}');
      buffer.writeln('Geological Period: ${specimen['geologicalPeriod']}');
      buffer.writeln('Formation: ${specimen['formation']}');
      if (specimen['description'] != null) {
        buffer.writeln('Description: ${specimen['description']}');
      }
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
        final anchor = html.AnchorElement(href: url)
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format exported successfully'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.dark),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _isMultiSelectMode = false;
      _selectedSpecimens.clear();
    });
  }

  void _showExportError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Export failed. Please try again.'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int get _totalSpecimens => _allSpecimens.length;

  double get _averageAccuracy {
    if (_allSpecimens.isEmpty) return 0.0;
    final total = _allSpecimens.fold<double>(
      0.0,
      (sum, specimen) => sum + (specimen['confidence'] as double),
    );
    return total / _allSpecimens.length;
  }

  int get _geographicCoverage {
    final locations = _allSpecimens
        .map((specimen) => specimen['location'] as String)
        .toSet();
    return locations.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Collection Manager',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          elevation: 2,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading specimen collection...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isMultiSelectMode
              ? '${_selectedSpecimens.length} Selected'
              : 'Collection Manager',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 2,
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedSpecimens.clear();
                  });
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
        actions: _isMultiSelectMode
            ? [
                IconButton(
                  onPressed:
                      _selectedSpecimens.isNotEmpty ? _showExportOptions : null,
                  icon: CustomIconWidget(
                    iconName: 'file_download',
                    color: _selectedSpecimens.isNotEmpty
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
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/database-browser'),
                  icon: CustomIconWidget(
                    iconName: 'search',
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
              totalSpecimens: _totalSpecimens,
              averageAccuracy: _averageAccuracy,
              geographicCoverage: _geographicCoverage,
            ),
            FilterSegmentControl(
              selectedIndex: _selectedFilterIndex,
              onSelectionChanged: _onFilterChanged,
              segments: _filterSegments,
            ),
            SearchSortBar(
              searchController: _searchController,
              onSearchChanged: (_) => _filterSpecimens(),
              onSortPressed: _showSortOptions,
              onMapToggle: _toggleMapView,
              isMapView: _isMapView,
            ),
            Expanded(
              child: _isMapView ? _buildMapView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_filteredSpecimens.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 2.h),
      itemCount: _filteredSpecimens.length,
      itemBuilder: (context, index) {
        final specimen = _filteredSpecimens[index];
        final specimenId = specimen['id'] as int;

        return SpecimenCard(
          specimen: specimen,
          isSelected: _selectedSpecimens.contains(specimenId),
          onTap: () => _onSpecimenTap(specimen),
          onSelectionChanged: _isMultiSelectMode
              ? (selected) => _toggleSpecimenSelection(specimenId)
              : (selected) => _onSpecimenLongPress(specimenId),
          onEdit: () =>
              Navigator.pushNamed(context, '/specimen-identification', arguments: specimen),
          onAddNotes: () => Navigator.pushNamed(context, '/field-notes'),
          onViewLocation: () =>
              Navigator.pushNamed(context, '/database-browser'),
          onRemove: () => _removeSpecimen(specimenId),
          onShare: () => _shareSpecimen(specimen),
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
            'Interactive Map View',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Specimen locations plotted on interactive map\nwith depth visualization and clustering',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            '${_filteredSpecimens.length} specimens ready to display',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
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
                ? 'Try adjusting your search terms\nor browse the complete database'
                : 'Start capturing specimens to build your collection',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/camera-capture'),
                icon: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: const Text('Capture'),
              ),
              SizedBox(width: 2.w),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/database-browser'),
                icon: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Browse'),
              ),
            ],
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allSpecimens
                    .removeWhere((specimen) => specimen['id'] == specimenId);
                _selectedSpecimens.remove(specimenId);
              });
              _filterSpecimens();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Specimen removed from collection'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Remove',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _shareSpecimen(Map<String, dynamic> specimen) {
    final shareText = '''
RockScope Analysis Result

Specimen: ${specimen['name']}
Category: ${specimen['category'] ?? 'Unknown'}
Confidence: ${specimen['confidence']}%
Location: ${specimen['location']}
Date: ${specimen['date']}
Status: ${specimen['status']}

Generated by RockScope Analyzer
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${specimen['name']}'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // In a real app, this would copy to clipboard
          },
        ),
      ),
    );
  }
}