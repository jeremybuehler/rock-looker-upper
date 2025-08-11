import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/search_header_widget.dart';
import './widgets/voice_recording_widget.dart';

/// Enhanced Field Notes screen using the FieldNotesService
class FieldNotesImproved extends StatefulWidget {
  const FieldNotesImproved({super.key});

  @override
  State<FieldNotesImproved> createState() => _FieldNotesImprovedState();
}

class _FieldNotesImprovedState extends State<FieldNotesImproved> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final FieldNotesService _fieldNotesService = FieldNotesService();

  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  bool _isMultiSelectMode = false;
  Set<String> _selectedNoteIds = {};
  List<Map<String, dynamic>> _filteredNotes = [];
  bool _isLoading = true;
  bool _hasActiveFilters = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _filteredNotes = _fieldNotesService.getAllFieldNotes().map((note) {
          return {
            ...note,
            'date': _parseDate(note['date'] as String),
            'hasAudio': note['images'] > 5,
            'hasPhotos': note['images'] > 0,
            'syncStatus': _getSyncStatus(),
            'isShared': note['priority'] == 'high',
            'collaborators': note['priority'] == 'high' ? [
              {'id': '1', 'name': 'Dr. Sarah Chen'},
              {'id': '2', 'name': 'Marcus Rodriguez'},
            ] : [],
            'preview': note['notes'],
            'specimens': _generateSpecimenList(note['specimens'] as List<int>),
            'weather': {
              'temperature': 25,
              'condition': 'sunny',
              'humidity': 70,
              'windSpeed': 10,
            },
          };
        }).toList();
        _isLoading = false;
      });
    });
  }

  DateTime _parseDate(String dateStr) {
    // Convert "Aug 8, 2025" format to DateTime
    try {
      final parts = dateStr.split(' ');
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final month = months[parts[0]] ?? 8;
      final day = int.parse(parts[1].replaceAll(',', ''));
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (e) {
      return DateTime.now().subtract(Duration(days: 1));
    }
  }

  String _getSyncStatus() {
    final statuses = ['synced', 'pending', 'offline', 'error'];
    return statuses[(DateTime.now().millisecond % statuses.length)];
  }

  List<Map<String, dynamic>> _generateSpecimenList(List<int> specimenIds) {
    return specimenIds.map((id) => {
      'id': 'spec_$id',
      'name': 'Rock Specimen #$id',
      'imageUrl': 'https://images.pexels.com/photos/1029604/pexels-photo-1029604.jpeg?auto=compress&cs=tinysrgb&w=800',
      'type': 'Rock Formations',
    }).toList();
  }

  void _onScroll() {
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
      appBar: AppBar(
        title: Text(
          'Field Notes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => _showStats(),
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(theme, colorScheme),
      floatingActionButton:
          _isMultiSelectMode ? null : _buildFloatingActionButton(context),
      bottomNavigationBar:
          _isMultiSelectMode ? _buildMultiSelectBottomBar(context) : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading field notes...'),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        SearchHeaderWidget(
          searchQuery: _searchQuery,
          onSearchChanged: _onSearchChanged,
          onNewNote: _onNewNote,
          onFilter: _showFilterBottomSheet,
          hasActiveFilters: _hasActiveFilters,
          onVoiceSearch: _showVoiceRecording,
        ),

        // Stats summary
        if (!_hasActiveFilters && _searchQuery.isEmpty) ...[
          Container(
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem('Total Notes', '${_filteredNotes.length}', Icons.note),
                ),
                Expanded(
                  child: _buildStatItem('High Priority', '${_getHighPriorityCount()}', Icons.priority_high),
                ),
                Expanded(
                  child: _buildStatItem('This Week', '${_getThisWeekCount()}', Icons.calendar_today),
                ),
              ],
            ),
          ),
        ],

        Expanded(
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            color: colorScheme.primary,
            child: _buildNotesList(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 24,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  int _getHighPriorityCount() {
    return _filteredNotes.where((note) => note['priority'] == 'high').length;
  }

  int _getThisWeekCount() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _filteredNotes.where((note) {
      final noteDate = note['date'] as DateTime;
      return noteDate.isAfter(weekAgo);
    }).length;
  }

  Widget _buildNotesList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      if (_searchQuery.isEmpty && !_hasActiveFilters) {
        _filteredNotes = _fieldNotesService.getAllFieldNotes().map((note) {
          return {
            ...note,
            'date': _parseDate(note['date'] as String),
            'hasAudio': note['images'] > 5,
            'hasPhotos': note['images'] > 0,
            'syncStatus': _getSyncStatus(),
            'isShared': note['priority'] == 'high',
            'collaborators': note['priority'] == 'high' ? [
              {'id': '1', 'name': 'Dr. Sarah Chen'},
              {'id': '2', 'name': 'Marcus Rodriguez'},
            ] : [],
            'preview': note['notes'],
            'specimens': _generateSpecimenList(note['specimens'] as List<int>),
            'weather': {
              'temperature': 25,
              'condition': 'sunny',
              'humidity': 70,
              'windSpeed': 10,
            },
          };
        }).toList();
      } else {
        var notes = _fieldNotesService.searchFieldNotes(_searchQuery);
        
        // Apply additional filters
        if (_activeFilters['priority'] != null) {
          notes = notes.where((note) => note['priority'] == _activeFilters['priority']).toList();
        }

        _filteredNotes = notes.map((note) {
          return {
            ...note,
            'date': _parseDate(note['date'] as String),
            'hasAudio': note['images'] > 5,
            'hasPhotos': note['images'] > 0,
            'syncStatus': _getSyncStatus(),
            'isShared': note['priority'] == 'high',
            'collaborators': note['priority'] == 'high' ? [
              {'id': '1', 'name': 'Dr. Sarah Chen'},
              {'id': '2', 'name': 'Marcus Rodriguez'},
            ] : [],
            'preview': note['notes'],
            'specimens': _generateSpecimenList(note['specimens'] as List<int>),
            'weather': {
              'temperature': 25,
              'condition': 'sunny',
              'humidity': 70,
              'windSpeed': 10,
            },
          };
        }).toList();
      }
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

  void _showStats() {
    final stats = _fieldNotesService.getFieldNoteStats();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Field Notes Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Notes: ${stats['total']}'),
            Text('High Priority: ${stats['high_priority']}'),
            Text('Medium Priority: ${stats['medium_priority']}'),
            Text('Low Priority: ${stats['low_priority']}'),
            Text('This Week: ${stats['this_week']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  bool _checkHasActiveFilters(Map<String, dynamic> filters) {
    return filters['priority'] != null ||
        filters['dateRange'] != null ||
        (filters['specimenTypes'] as List?)?.isNotEmpty == true ||
        (filters['teamMembers'] as List?)?.isNotEmpty == true ||
        (filters['syncStatus'] as String?) != 'all';
  }

  void _clearSearchAndFilters() {
    setState(() {
      _searchQuery = '';
      _activeFilters.clear();
      _hasActiveFilters = false;
      _filterNotes();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    _loadNotes();

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
          _isMultiSelectMode = false;
          _selectedNoteIds.clear();
        }
      } else {
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
      _showNoteDetail(note);
    }
  }

  void _onNewNote() {
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
      _filteredNotes.removeWhere((n) => n["id"] == note["id"]);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Location: ${note['location']}'),
              SizedBox(height: 1.h),
              Text('Priority: ${note['priority']}'),
              SizedBox(height: 1.h),
              Text('Specimens: ${(note['specimens'] as List).length}'),
              SizedBox(height: 2.h),
              Text(note['preview']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/specimen-identification');
            },
            child: const Text('View Specimens'),
          ),
        ],
      ),
    );
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