/// Riverpod providers for field notes management
/// 
/// Provides centralized state management for field notes, voice recordings,
/// and location-based research data
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/field_notes_service.dart';

/// Provider for the field notes service singleton
final fieldNotesServiceProvider = Provider<FieldNotesService>((ref) {
  return FieldNotesService.instance;
});

/// Provider for all field notes
final fieldNotesProvider = StateNotifierProvider<FieldNotesNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return FieldNotesNotifier(ref.read(fieldNotesServiceProvider));
});

/// State notifier for managing field notes
class FieldNotesNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  FieldNotesNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadNotes();
  }

  final FieldNotesService _service;

  /// Load all field notes
  Future<void> _loadNotes() async {
    try {
      state = const AsyncValue.loading();
      final notes = await _service.getAllNotes();
      state = AsyncValue.data(notes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Add a new field note
  Future<void> addNote({
    required String title,
    required String content,
    String? location,
    String? voiceRecordingPath,
    List<String>? imageUrls,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final note = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'content': content,
        'location': location,
        'voiceRecordingPath': voiceRecordingPath,
        'imageUrls': imageUrls ?? [],
        'metadata': metadata ?? {},
        'dateCreated': DateTime.now().toIso8601String(),
        'dateModified': DateTime.now().toIso8601String(),
      };

      await _service.saveNote(note);
      await _loadNotes(); // Refresh the list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update an existing field note
  Future<void> updateNote(Map<String, dynamic> note) async {
    try {
      note['dateModified'] = DateTime.now().toIso8601String();
      await _service.saveNote(note);
      await _loadNotes(); // Refresh the list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a field note
  Future<void> deleteNote(String noteId) async {
    try {
      await _service.deleteNote(noteId);
      await _loadNotes(); // Refresh the list
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Search notes by query
  Future<void> searchNotes(String query) async {
    try {
      state = const AsyncValue.loading();
      final notes = await _service.searchNotes(query);
      state = AsyncValue.data(notes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refresh notes from storage
  Future<void> refresh() async {
    await _loadNotes();
  }
}

/// Provider for field notes search query
final fieldNotesSearchProvider = StateProvider<String>((ref) => '');

/// Provider for filtered field notes based on search
final filteredFieldNotesProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final notesAsync = ref.watch(fieldNotesProvider);
  final searchQuery = ref.watch(fieldNotesSearchProvider);

  return notesAsync.when(
    data: (notes) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(notes);
      }

      final query = searchQuery.toLowerCase();
      final filtered = notes.where((note) {
        final title = (note['title'] as String? ?? '').toLowerCase();
        final content = (note['content'] as String? ?? '').toLowerCase();
        final location = (note['location'] as String? ?? '').toLowerCase();
        
        return title.contains(query) ||
               content.contains(query) ||
               location.contains(query);
      }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for field notes sorting
final fieldNotesSortProvider = StateProvider<FieldNotesSortOption>((ref) => FieldNotesSortOption.dateCreated);

enum FieldNotesSortOption {
  dateCreated('Date Created'),
  dateModified('Date Modified'),
  title('Title'),
  location('Location');

  const FieldNotesSortOption(this.displayName);
  final String displayName;
}

/// Provider for sorted field notes
final sortedFieldNotesProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final filteredNotes = ref.watch(filteredFieldNotesProvider);
  final sortOption = ref.watch(fieldNotesSortProvider);

  return filteredNotes.when(
    data: (notes) {
      final sorted = List<Map<String, dynamic>>.from(notes);

      switch (sortOption) {
        case FieldNotesSortOption.dateCreated:
          sorted.sort((a, b) {
            final dateA = DateTime.tryParse(a['dateCreated'] as String? ?? '');
            final dateB = DateTime.tryParse(b['dateCreated'] as String? ?? '');
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA); // Most recent first
          });
          break;

        case FieldNotesSortOption.dateModified:
          sorted.sort((a, b) {
            final dateA = DateTime.tryParse(a['dateModified'] as String? ?? '');
            final dateB = DateTime.tryParse(b['dateModified'] as String? ?? '');
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA); // Most recent first
          });
          break;

        case FieldNotesSortOption.title:
          sorted.sort((a, b) {
            final titleA = a['title'] as String? ?? '';
            final titleB = b['title'] as String? ?? '';
            return titleA.compareTo(titleB);
          });
          break;

        case FieldNotesSortOption.location:
          sorted.sort((a, b) {
            final locationA = a['location'] as String? ?? '';
            final locationB = b['location'] as String? ?? '';
            final locationCompare = locationA.compareTo(locationB);
            if (locationCompare != 0) return locationCompare;
            
            // Secondary sort by date if locations are the same
            final dateA = DateTime.tryParse(a['dateCreated'] as String? ?? '');
            final dateB = DateTime.tryParse(b['dateCreated'] as String? ?? '');
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA);
          });
          break;
      }

      return AsyncValue.data(sorted);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for voice recording state
final voiceRecordingProvider = StateNotifierProvider<VoiceRecordingNotifier, VoiceRecordingState>((ref) {
  return VoiceRecordingNotifier();
});

/// Voice recording state
class VoiceRecordingState {
  const VoiceRecordingState({
    this.isRecording = false,
    this.recordingPath,
    this.duration = Duration.zero,
    this.error,
  });

  final bool isRecording;
  final String? recordingPath;
  final Duration duration;
  final String? error;

  VoiceRecordingState copyWith({
    bool? isRecording,
    String? recordingPath,
    Duration? duration,
    String? error,
  }) {
    return VoiceRecordingState(
      isRecording: isRecording ?? this.isRecording,
      recordingPath: recordingPath ?? this.recordingPath,
      duration: duration ?? this.duration,
      error: error ?? this.error,
    );
  }
}

/// State notifier for voice recording
class VoiceRecordingNotifier extends StateNotifier<VoiceRecordingState> {
  VoiceRecordingNotifier() : super(const VoiceRecordingState());

  /// Start voice recording
  Future<void> startRecording() async {
    try {
      state = state.copyWith(
        isRecording: true,
        error: null,
        duration: Duration.zero,
      );
      
      // In a real implementation, you would start the actual recording here
      // For now, we'll simulate it
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        error: e.toString(),
      );
    }
  }

  /// Stop voice recording
  Future<void> stopRecording() async {
    try {
      if (!state.isRecording) return;

      // In a real implementation, you would stop the recording and get the path
      final recordingPath = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      
      state = state.copyWith(
        isRecording: false,
        recordingPath: recordingPath,
      );
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        error: e.toString(),
      );
    }
  }

  /// Cancel voice recording
  void cancelRecording() {
    state = const VoiceRecordingState();
  }

  /// Update recording duration (called by timer)
  void updateDuration(Duration duration) {
    if (state.isRecording) {
      state = state.copyWith(duration: duration);
    }
  }
}

/// Provider for current location
final currentLocationProvider = StateNotifierProvider<CurrentLocationNotifier, LocationState>((ref) {
  return CurrentLocationNotifier();
});

/// Location state
class LocationState {
  const LocationState({
    this.location,
    this.isLoading = false,
    this.error,
  });

  final String? location;
  final bool isLoading;
  final String? error;

  LocationState copyWith({
    String? location,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// State notifier for current location
class CurrentLocationNotifier extends StateNotifier<LocationState> {
  CurrentLocationNotifier() : super(const LocationState());

  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // In a real implementation, you would get the actual GPS location
      // For now, we'll simulate it
      await Future.delayed(const Duration(seconds: 1));
      
      final location = 'Lat: ${(37.7749 + (0.1 - 0.2 * (DateTime.now().millisecond / 1000))).toStringAsFixed(6)}, '
                      'Lng: ${(-122.4194 + (0.1 - 0.2 * (DateTime.now().second / 60))).toStringAsFixed(6)}';
      
      state = state.copyWith(
        location: location,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear current location
  void clearLocation() {
    state = const LocationState();
  }
}

/// Provider for field notes statistics
final fieldNotesStatsProvider = Provider<FieldNotesStats>((ref) {
  final notesAsync = ref.watch(fieldNotesProvider);
  
  return notesAsync.when(
    data: (notes) => FieldNotesStats.fromNotes(notes),
    loading: () => const FieldNotesStats(),
    error: (_, __) => const FieldNotesStats(),
  );
});

/// Field notes statistics model
class FieldNotesStats {
  const FieldNotesStats({
    this.totalNotes = 0,
    this.notesWithVoice = 0,
    this.notesWithImages = 0,
    this.recentNotes = 0,
    this.locations = const {},
  });

  final int totalNotes;
  final int notesWithVoice;
  final int notesWithImages;
  final int recentNotes; // Notes from last 7 days
  final Set<String> locations;

  factory FieldNotesStats.fromNotes(List<Map<String, dynamic>> notes) {
    if (notes.isEmpty) {
      return const FieldNotesStats();
    }

    int notesWithVoice = 0;
    int notesWithImages = 0;
    int recentNotes = 0;
    final locations = <String>{};
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    for (final note in notes) {
      // Voice recordings
      if (note['voiceRecordingPath'] != null) {
        notesWithVoice++;
      }

      // Images
      final imageUrls = note['imageUrls'] as List<String>? ?? [];
      if (imageUrls.isNotEmpty) {
        notesWithImages++;
      }

      // Recent notes
      final dateCreated = DateTime.tryParse(note['dateCreated'] as String? ?? '');
      if (dateCreated != null && dateCreated.isAfter(weekAgo)) {
        recentNotes++;
      }

      // Locations
      final location = note['location'] as String?;
      if (location != null && location.isNotEmpty) {
        locations.add(location);
      }
    }

    return FieldNotesStats(
      totalNotes: notes.length,
      notesWithVoice: notesWithVoice,
      notesWithImages: notesWithImages,
      recentNotes: recentNotes,
      locations: locations,
    );
  }
}