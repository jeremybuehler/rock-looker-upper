import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/search_header_widget.dart';
import './widgets/voice_recording_widget.dart';

/// Field Notes screen for managing research observations and specimen documentation
/// with location-aware organization for comprehensive field studies
class FieldNotes extends StatefulWidget {
  const FieldNotes({super.key});

  @override
  State<FieldNotes> createState() => _FieldNotesState();
}

class _FieldNotesState extends State<FieldNotes> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  bool _isMultiSelectMode = false;
  Set<String> _selectedNoteIds = {};
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isLoading = false;
  bool _hasActiveFilters = false;

  // Mock field notes data with comprehensive research information
  final List<Map<String, dynamic>> _mockNotes = [
    {
      "id": "note_001",
      "title": "Coral Reef Formation Analysis - Site Alpha",
      "date": DateTime.now().subtract(const Duration(hours: 2)),
      "location": "Great Barrier Reef, Queensland (-16.2839, 145.7781)",
      "weather": {
        "temperature": 28,
        "condition": "sunny",
        "humidity": 75,
        "windSpeed": 12
      },
      "preview":
          "Discovered extensive staghorn coral formations with unusual branching patterns. Water temperature measured at 28.5°C with excellent visibility (30m+). Observed significant marine biodiversity including parrotfish, angelfish, and sea turtles. Coral health appears excellent with minimal bleaching observed.",
      "specimens": [
        {
          "id": "spec_001",
          "name": "Staghorn Coral",
          "imageUrl":
              "https://images.pexels.com/photos/920161/pexels-photo-920161.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Marine Life"
        },
        {
          "id": "spec_002",
          "name": "Giant Clam Shell",
          "imageUrl":
              "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Marine Life"
        }
      ],
      "hasAudio": true,
      "hasPhotos": true,
      "syncStatus": "synced",
      "isShared": true,
      "collaborators": [
        {"id": "1", "name": "Dr. Sarah Chen"},
        {"id": "2", "name": "Marcus Rodriguez"},
        {"id": "3", "name": "Dr. Emily Watson"}
      ]
    },
    {
      "id": "note_002",
      "title": "Sedimentary Rock Layer Documentation",
      "date": DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      "location": "Coastal Cliff Formation, NSW (-33.8688, 151.2093)",
      "weather": {
        "temperature": 22,
        "condition": "cloudy",
        "humidity": 68,
        "windSpeed": 8
      },
      "preview":
          "Identified distinct sedimentary layers dating approximately 150-200 million years. Limestone and sandstone alternating patterns suggest periodic marine transgression. Fossil fragments embedded in middle layers require further analysis. GPS coordinates recorded for detailed geological survey.",
      "specimens": [
        {
          "id": "spec_003",
          "name": "Limestone Sample",
          "imageUrl":
              "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Rock Formations"
        }
      ],
      "hasAudio": false,
      "hasPhotos": true,
      "syncStatus": "pending",
      "isShared": false,
      "collaborators": []
    },
    {
      "id": "note_003",
      "title": "Marine Artifact Discovery - Anchor Fragment",
      "date": DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      "location": "Shipwreck Site Beta, Torres Strait (-10.5917, 142.2583)",
      "weather": {
        "temperature": 26,
        "condition": "rainy",
        "humidity": 82,
        "windSpeed": 15
      },
      "preview":
          "Located iron anchor fragment approximately 2.5m in length, heavily corroded but structurally intact. Preliminary assessment suggests 18th-19th century origin based on design characteristics. Surrounding area shows additional debris field requiring systematic excavation. Photogrammetry completed for 3D modeling.",
      "specimens": [
        {
          "id": "spec_004",
          "name": "Iron Anchor Fragment",
          "imageUrl":
              "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Artifacts"
        },
        {
          "id": "spec_005",
          "name": "Ceramic Shard",
          "imageUrl":
              "https://images.pexels.com/photos/920161/pexels-photo-920161.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Artifacts"
        },
        {
          "id": "spec_006",
          "name": "Metal Concretion",
          "imageUrl":
              "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Artifacts"
        }
      ],
      "hasAudio": true,
      "hasPhotos": true,
      "syncStatus": "synced",
      "isShared": true,
      "collaborators": [
        {"id": "4", "name": "James Park"},
        {"id": "5", "name": "Dr. Lisa Thompson"}
      ]
    },
    {
      "id": "note_004",
      "title": "Mineral Composition Study - Quartz Veins",
      "date": DateTime.now().subtract(const Duration(days: 3, hours: 7)),
      "location": "Rocky Outcrop Formation, WA (-31.9505, 115.8605)",
      "weather": {
        "temperature": 31,
        "condition": "sunny",
        "humidity": 45,
        "windSpeed": 6
      },
      "preview":
          "Extensive quartz vein system running through granite host rock. Veins show clear crystalline structure with minor pyrite inclusions. Strike and dip measurements recorded: 045°/65°NW. Samples collected for XRD analysis to determine exact mineral composition and formation temperature.",
      "specimens": [
        {
          "id": "spec_007",
          "name": "Quartz Crystal",
          "imageUrl":
              "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Minerals"
        }
      ],
      "hasAudio": false,
      "hasPhotos": true,
      "syncStatus": "offline",
      "isShared": false,
      "collaborators": []
    },
    {
      "id": "note_005",
      "title": "Fossil Shell Bed Investigation",
      "date": DateTime.now().subtract(const Duration(days: 5, hours: 2)),
      "location": "Paleontological Site Gamma, SA (-34.9285, 138.6007)",
      "weather": {
        "temperature": 19,
        "condition": "windy",
        "humidity": 58,
        "windSpeed": 22
      },
      "preview":
          "Dense concentration of fossilized brachiopod and gastropod shells in mudstone matrix. Preservation quality excellent with original shell structure visible. Stratigraphic position suggests Permian age (approximately 280 million years). Site requires protection from erosion and unauthorized collection.",
      "specimens": [
        {
          "id": "spec_008",
          "name": "Brachiopod Fossil",
          "imageUrl":
              "https://images.pexels.com/photos/920161/pexels-photo-920161.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Fossils"
        },
        {
          "id": "spec_009",
          "name": "Gastropod Shell",
          "imageUrl":
              "https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Fossils"
        }
      ],
      "hasAudio": true,
      "hasPhotos": true,
      "syncStatus": "error",
      "isShared": true,
      "collaborators": [
        {"id": "1", "name": "Dr. Sarah Chen"},
        {"id": "3", "name": "Dr. Emily Watson"}
      ]
    },
    {
      "id": "note_006",
      "title": "Underwater Cave System Mapping",
      "date": DateTime.now().subtract(const Duration(days: 7, hours: 4)),
      "location": "Blue Hole Formation, QLD (-25.2744, 153.1178)",
      "weather": {
        "temperature": 24,
        "condition": "overcast",
        "humidity": 71,
        "windSpeed": 10
      },
      "preview":
          "Preliminary survey of underwater cave system extending 45m depth. Limestone formations show extensive speleothem development. Water clarity excellent for photogrammetry. Discovered previously unmapped chamber with unique flowstone formations. Safety protocols strictly followed with dive buddy system.",
      "specimens": [
        {
          "id": "spec_010",
          "name": "Flowstone Sample",
          "imageUrl":
              "https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800",
          "type": "Rock Formations"
        }
      ],
      "hasAudio": false,
      "hasPhotos": true,
      "syncStatus": "pending",
      "isShared": false,
      "collaborators": []
    }
  ];

  @override
  void initState() {
    super.initState();
    _filteredNotes = List.from(_mockNotes);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle infinite scroll or other scroll-based actions
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more notes if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          SearchHeaderWidget(
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onNewNote: _onNewNote,
            onFilter: _showFilterBottomSheet,
            hasActiveFilters: _hasActiveFilters,
            onVoiceSearch: _showVoiceRecording,
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              color: colorScheme.primary,
              child: _buildNotesList(context),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _isMultiSelectMode ? null : _buildFloatingActionButton(context),
      bottomNavigationBar:
          _isMultiSelectMode ? _buildMultiSelectBottomBar(context) : null,
    );
  }

  Widget _buildNotesList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (_filteredNotes.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        top: 1.h,
        bottom: _isMultiSelectMode ? 12.h : 10.h,
      ),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        final isSelected = _selectedNoteIds.contains(note["id"]);

        return GestureDetector(
          onLongPress: () => _toggleMultiSelectMode(note["id"] as String),
          child: NoteCardWidget(
            noteData: note,
            isSelected: isSelected,
            onTap: () => _onNoteTap(note),
            onEdit: () => _onEditNote(note),
            onDuplicate: () => _onDuplicateNote(note),
            onShare: () => _onShareNote(note),
            onArchive: () => _onArchiveNote(note),
            onDelete: () => _onDeleteNote(note),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'note_add',
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 3.h),
            Text(
              _searchQuery.isNotEmpty || _hasActiveFilters
                  ? 'No notes found'
                  : 'Start Your Field Research',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty || _hasActiveFilters
                  ? 'Try adjusting your search or filters'
                  : 'Create your first field note to document specimens and observations',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: _searchQuery.isNotEmpty || _hasActiveFilters
                  ? _clearSearchAndFilters
                  : _onNewNote,
              icon: CustomIconWidget(
                iconName: _searchQuery.isNotEmpty || _hasActiveFilters
                    ? 'clear'
                    : 'add',
                size: 20,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                _searchQuery.isNotEmpty || _hasActiveFilters
                    ? 'Clear Filters'
                    : 'Create Note',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FloatingActionButton.extended(
      onPressed: _onNewNote,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: CustomIconWidget(
        iconName: 'add',
        size: 24,
        color: colorScheme.onPrimary,
      ),
      label: Text(
        'New Note',
        style: theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMultiSelectBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '${_selectedNoteIds.length} selected',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed:
                  _selectedNoteIds.isNotEmpty ? _exportSelectedNotes : null,
              icon: CustomIconWidget(
                iconName: 'file_download',
                size: 24,
                color: _selectedNoteIds.isNotEmpty
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              tooltip: 'Export',
            ),
            IconButton(
              onPressed:
                  _selectedNoteIds.isNotEmpty ? _shareSelectedNotes : null,
              icon: CustomIconWidget(
                iconName: 'share',
                size: 24,
                color: _selectedNoteIds.isNotEmpty
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              tooltip: 'Share',
            ),
            IconButton(
              onPressed:
                  _selectedNoteIds.isNotEmpty ? _archiveSelectedNotes : null,
              icon: CustomIconWidget(
                iconName: 'archive',
                size: 24,
                color: _selectedNoteIds.isNotEmpty
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              tooltip: 'Archive',
            ),
            IconButton(
              onPressed: () => _toggleMultiSelectMode(null),
              icon: CustomIconWidget(
                iconName: 'close',
                size: 24,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              tooltip: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterNotes();
    });
  }

  void _filterNotes() {
    setState(() {
      _filteredNotes = _mockNotes.where((note) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          final titleMatch =
              (note["title"] as String).toLowerCase().contains(searchLower);
          final locationMatch = (note["location"] as String? ?? "")
              .toLowerCase()
              .contains(searchLower);
          final previewMatch =
              (note["preview"] as String).toLowerCase().contains(searchLower);

          if (!titleMatch && !locationMatch && !previewMatch) {
            return false;
          }
        }

        // Date range filter
        if (_activeFilters['dateRange'] != null) {
          final dateRange = _activeFilters['dateRange'] as DateTimeRange;
          final noteDate = note["date"] as DateTime;
          if (noteDate.isBefore(dateRange.start) ||
              noteDate.isAfter(dateRange.end)) {
            return false;
          }
        }

        // Specimen type filter
        if (_activeFilters['specimenTypes'] != null &&
            (_activeFilters['specimenTypes'] as List).isNotEmpty) {
          final selectedTypes = _activeFilters['specimenTypes'] as List<String>;
          final specimens = (note["specimens"] as List?) ?? [];
          final hasMatchingSpecimen = specimens
              .any((specimen) => selectedTypes.contains(specimen["type"]));
          if (!hasMatchingSpecimen) {
            return false;
          }
        }

        // Team member filter
        if (_activeFilters['teamMembers'] != null &&
            (_activeFilters['teamMembers'] as List).isNotEmpty) {
          final selectedMembers = _activeFilters['teamMembers'] as List<String>;
          final collaborators = (note["collaborators"] as List?) ?? [];
          final hasMatchingCollaborator = collaborators.any(
              (collaborator) => selectedMembers.contains(collaborator["id"]));
          if (!hasMatchingCollaborator && selectedMembers.isNotEmpty) {
            return false;
          }
        }

        // Sync status filter
        if (_activeFilters['syncStatus'] != null &&
            _activeFilters['syncStatus'] != 'all') {
          final selectedStatus = _activeFilters['syncStatus'] as String;
          if (note["syncStatus"] != selectedStatus) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
            _hasActiveFilters = _checkHasActiveFilters(filters);
            _filterNotes();
          });
        },
      ),
    );
  }

  void _showVoiceRecording() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceRecordingWidget(
        onRecordingComplete: (path) {
          Navigator.of(context).pop();
          _handleVoiceRecording(path);
        },
        onRecordingCancelled: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  bool _checkHasActiveFilters(Map<String, dynamic> filters) {
    return filters['dateRange'] != null ||
        (filters['specimenTypes'] as List?)?.isNotEmpty == true ||
        (filters['teamMembers'] as List?)?.isNotEmpty == true ||
        (filters['syncStatus'] as String?) != 'all';
  }

  void _clearSearchAndFilters() {
    setState(() {
      _searchQuery = '';
      _activeFilters.clear();
      _hasActiveFilters = false;
      _filteredNotes = List.from(_mockNotes);
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      // In a real app, this would refresh data from the server
      _filterNotes();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes synchronized successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleMultiSelectMode(String? noteId) {
    setState(() {
      if (_isMultiSelectMode) {
        if (noteId != null) {
          if (_selectedNoteIds.contains(noteId)) {
            _selectedNoteIds.remove(noteId);
          } else {
            _selectedNoteIds.add(noteId);
          }
        } else {
          // Exit multi-select mode
          _isMultiSelectMode = false;
          _selectedNoteIds.clear();
        }
      } else {
        // Enter multi-select mode
        _isMultiSelectMode = true;
        if (noteId != null) {
          _selectedNoteIds.add(noteId);
        }
      }
    });
  }

  void _onNoteTap(Map<String, dynamic> note) {
    if (_isMultiSelectMode) {
      _toggleMultiSelectMode(note["id"] as String);
    } else {
      // Navigate to note detail view
      _showNoteDetail(note);
    }
  }

  void _onNewNote() {
    // Navigate to new note creation screen
    Navigator.pushNamed(context, '/camera-capture');
  }

  void _onEditNote(Map<String, dynamic> note) {
    _showSnackBar('Editing note: ${note["title"]}');
  }

  void _onDuplicateNote(Map<String, dynamic> note) {
    _showSnackBar('Duplicating note: ${note["title"]}');
  }

  void _onShareNote(Map<String, dynamic> note) {
    _showSnackBar('Sharing note: ${note["title"]}');
  }

  void _onArchiveNote(Map<String, dynamic> note) {
    _showSnackBar('Archiving note: ${note["title"]}');
  }

  void _onDeleteNote(Map<String, dynamic> note) {
    setState(() {
      _mockNotes.removeWhere((n) => n["id"] == note["id"]);
      _filterNotes();
    });
    _showSnackBar('Note deleted: ${note["title"]}');
  }

  void _exportSelectedNotes() {
    _showSnackBar('Exporting ${_selectedNoteIds.length} notes');
    _toggleMultiSelectMode(null);
  }

  void _shareSelectedNotes() {
    _showSnackBar('Sharing ${_selectedNoteIds.length} notes');
    _toggleMultiSelectMode(null);
  }

  void _archiveSelectedNotes() {
    _showSnackBar('Archiving ${_selectedNoteIds.length} notes');
    _toggleMultiSelectMode(null);
  }

  void _handleVoiceRecording(String path) {
    _showSnackBar('Voice recording saved: $path');
  }

  void _showNoteDetail(Map<String, dynamic> note) {
    Navigator.pushNamed(context, '/specimen-identification');
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
