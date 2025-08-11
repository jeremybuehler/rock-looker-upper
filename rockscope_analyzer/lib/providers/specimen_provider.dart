/// Riverpod providers for specimen data management
/// 
/// Provides centralized state management for rock specimen data
/// with offline-first architecture and search capabilities
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/specimen_model.dart';
import '../services/rock_database_service.dart';

/// Provider for the rock database service singleton
final rockDatabaseServiceProvider = Provider<RockDatabaseService>((ref) {
  return RockDatabaseService.instance;
});

/// Provider for all available specimens in the database
final specimenDatabaseProvider = FutureProvider<List<SpecimenModel>>((ref) async {
  final service = ref.read(rockDatabaseServiceProvider);
  return service.getAllSpecimens();
});

/// Provider for user's collected specimens
final collectionProvider = StateNotifierProvider<CollectionNotifier, List<SpecimenModel>>((ref) {
  return CollectionNotifier(ref.read(rockDatabaseServiceProvider));
});

/// State notifier for managing the user's collection
class CollectionNotifier extends StateNotifier<List<SpecimenModel>> {
  CollectionNotifier(this._service) : super([]) {
    _loadCollection();
  }

  final RockDatabaseService _service;

  /// Load the user's collection from storage
  Future<void> _loadCollection() async {
    try {
      final collection = await _service.getUserCollection();
      state = collection;
    } catch (e) {
      // Handle error - could log or show error state
      state = [];
    }
  }

  /// Add a specimen to the collection
  Future<void> addSpecimen(SpecimenModel specimen) async {
    try {
      await _service.addToCollection(specimen);
      state = [...state, specimen];
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Remove a specimen from the collection
  Future<void> removeSpecimen(String specimenId) async {
    try {
      await _service.removeFromCollection(specimenId);
      state = state.where((s) => s.id != specimenId).toList();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Update a specimen in the collection
  Future<void> updateSpecimen(SpecimenModel specimen) async {
    try {
      await _service.updateSpecimenInCollection(specimen);
      state = state.map((s) => s.id == specimen.id ? specimen : s).toList();
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Clear all specimens from the collection
  Future<void> clearCollection() async {
    try {
      await _service.clearCollection();
      state = [];
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  /// Refresh the collection from storage
  Future<void> refresh() async {
    await _loadCollection();
  }
}

/// Provider for search functionality
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered specimens based on search query
final filteredSpecimensProvider = Provider<AsyncValue<List<SpecimenModel>>>((ref) {
  final specimenDatabase = ref.watch(specimenDatabaseProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  return specimenDatabase.when(
    data: (specimens) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(specimens);
      }
      
      final filtered = specimens.where((specimen) {
        final query = searchQuery.toLowerCase();
        return specimen.scientificName.toLowerCase().contains(query) ||
               specimen.commonName.toLowerCase().contains(query) ||
               specimen.category.toLowerCase().contains(query) ||
               specimen.description.toLowerCase().contains(query);
      }).toList();
      
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider for filtered collection based on search query
final filteredCollectionProvider = Provider<List<SpecimenModel>>((ref) {
  final collection = ref.watch(collectionProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return collection;
  }

  final query = searchQuery.toLowerCase();
  return collection.where((specimen) {
    return specimen.scientificName.toLowerCase().contains(query) ||
           specimen.commonName.toLowerCase().contains(query) ||
           specimen.category.toLowerCase().contains(query) ||
           specimen.description.toLowerCase().contains(query);
  }).toList();
});

/// Provider for collection statistics
final collectionStatsProvider = Provider<CollectionStats>((ref) {
  final collection = ref.watch(collectionProvider);
  
  return CollectionStats.fromCollection(collection);
});

/// Collection statistics model
class CollectionStats {
  const CollectionStats({
    required this.totalSpecimens,
    required this.categoryCounts,
    required this.recentlyAdded,
    required this.averageConfidence,
  });

  final int totalSpecimens;
  final Map<String, int> categoryCounts;
  final int recentlyAdded; // Added in last 7 days
  final double averageConfidence;

  factory CollectionStats.fromCollection(List<SpecimenModel> collection) {
    if (collection.isEmpty) {
      return const CollectionStats(
        totalSpecimens: 0,
        categoryCounts: {},
        recentlyAdded: 0,
        averageConfidence: 0.0,
      );
    }

    // Count by category
    final categoryCounts = <String, int>{};
    double totalConfidence = 0.0;
    int recentlyAdded = 0;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));

    for (final specimen in collection) {
      // Category count
      categoryCounts[specimen.category] = (categoryCounts[specimen.category] ?? 0) + 1;
      
      // Confidence sum
      totalConfidence += specimen.confidence;
      
      // Recently added count
      if (specimen.dateAdded?.isAfter(weekAgo) ?? false) {
        recentlyAdded++;
      }
    }

    return CollectionStats(
      totalSpecimens: collection.length,
      categoryCounts: categoryCounts,
      recentlyAdded: recentlyAdded,
      averageConfidence: totalConfidence / collection.length,
    );
  }
}

/// Provider for sorting options
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.dateAdded);

/// Sorting options for specimens
enum SortOption {
  dateAdded('Date Added'),
  alphabetical('Alphabetical'),
  confidence('Confidence'),
  category('Category');

  const SortOption(this.displayName);
  final String displayName;
}

/// Provider for sorted collection
final sortedCollectionProvider = Provider<List<SpecimenModel>>((ref) {
  final collection = ref.watch(filteredCollectionProvider);
  final sortOption = ref.watch(sortOptionProvider);

  final sorted = List<SpecimenModel>.from(collection);

  switch (sortOption) {
    case SortOption.dateAdded:
      sorted.sort((a, b) {
        if (a.dateAdded == null && b.dateAdded == null) return 0;
        if (a.dateAdded == null) return 1;
        if (b.dateAdded == null) return -1;
        return b.dateAdded!.compareTo(a.dateAdded!);
      });
      break;
      
    case SortOption.alphabetical:
      sorted.sort((a, b) => a.scientificName.compareTo(b.scientificName));
      break;
      
    case SortOption.confidence:
      sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
      break;
      
    case SortOption.category:
      sorted.sort((a, b) {
        final categoryCompare = a.category.compareTo(b.category);
        if (categoryCompare != 0) return categoryCompare;
        return a.scientificName.compareTo(b.scientificName);
      });
      break;
  }

  return sorted;
});

/// Provider for filter options
final filterOptionsProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for available categories
final availableCategoriesProvider = Provider<Set<String>>((ref) {
  final collection = ref.watch(collectionProvider);
  return collection.map((s) => s.category).toSet();
});

/// Provider for filtered and sorted collection
final processedCollectionProvider = Provider<List<SpecimenModel>>((ref) {
  final sortedCollection = ref.watch(sortedCollectionProvider);
  final filterOptions = ref.watch(filterOptionsProvider);

  if (filterOptions.isEmpty) {
    return sortedCollection;
  }

  return sortedCollection.where((specimen) {
    return filterOptions.contains(specimen.category);
  }).toList();
});

/// Provider for multi-select mode
final multiSelectModeProvider = StateProvider<bool>((ref) => false);

/// Provider for selected specimens
final selectedSpecimensProvider = StateProvider<Set<String>>((ref) => {});

/// Provider for export options
final exportOptionsProvider = Provider<ExportOptions>((ref) {
  return const ExportOptions();
});

/// Export options model
class ExportOptions {
  const ExportOptions({
    this.includeImages = true,
    this.includeLocation = true,
    this.includeNotes = true,
    this.format = ExportFormat.csv,
  });

  final bool includeImages;
  final bool includeLocation;
  final bool includeNotes;
  final ExportFormat format;

  ExportOptions copyWith({
    bool? includeImages,
    bool? includeLocation,
    bool? includeNotes,
    ExportFormat? format,
  }) {
    return ExportOptions(
      includeImages: includeImages ?? this.includeImages,
      includeLocation: includeLocation ?? this.includeLocation,
      includeNotes: includeNotes ?? this.includeNotes,
      format: format ?? this.format,
    );
  }
}

enum ExportFormat {
  csv('CSV'),
  json('JSON'),
  pdf('PDF');

  const ExportFormat(this.displayName);
  final String displayName;
}