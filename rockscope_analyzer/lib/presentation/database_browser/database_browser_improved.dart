import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/alphabetical_index_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/search_suggestions_widget.dart';
import './widgets/symbol_card_widget.dart';

/// Enhanced Database Browser with comprehensive rock and mineral database
class DatabaseBrowserImproved extends StatefulWidget {
  const DatabaseBrowserImproved({super.key});

  @override
  State<DatabaseBrowserImproved> createState() => _DatabaseBrowserImprovedState();
}

class _DatabaseBrowserImprovedState extends State<DatabaseBrowserImproved>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RockDatabaseService _databaseService = RockDatabaseService();

  late TabController _tabController;

  String _selectedLetter = 'A';
  Map<String, List<String>> _activeFilters = {};
  List<Map<String, dynamic>> _filteredSpecimens = [];
  List<Map<String, dynamic>> _allSpecimens = [];
  bool _isSearching = false;
  bool _isLoading = true;

  final List<String> _recentSearches = [
    "Basalt formations",
    "Granite intrusions",
    "Sedimentary layers",
    "Metamorphic rocks",
    "Ocean floor specimens",
    "Hydrothermal deposits",
    "Volcanic glass",
    "Carbonate formations",
  ];

  final List<Map<String, dynamic>> _categoryShortcuts = [
    {
      "name": "Igneous",
      "icon": Icons.local_fire_department,
      "count": 8,
    },
    {
      "name": "Sedimentary", 
      "icon": Icons.layers,
      "count": 6,
    },
    {
      "name": "Metamorphic",
      "icon": Icons.change_circle,
      "count": 5,
    },
    {
      "name": "Marine Specimens",
      "icon": Icons.waves,
      "count": 12,
    },
    {
      "name": "Hydrothermal",
      "icon": Icons.hot_tub,
      "count": 4,
    },
    {
      "name": "Formations",
      "icon": Icons.terrain,
      "count": 15,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDatabase();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadDatabase() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () async {
      final specimens = await _databaseService.getAllSpecimens();
      setState(() {
        _allSpecimens = specimens.map((specimen) {
          return {
            'id': specimen.id,
            'name': specimen.name,
            'category': specimen.category,
            'subcategory': specimen.subcategory,
            'description': specimen.description,
            'imageUrl': specimen.imageUrl,
            'firstLetter': specimen.name.substring(0, 1).toUpperCase(),
            'image': specimen.imageUrl,
            'scientificName': specimen.scientificName,
            'geologicalPeriod': specimen.geologicalPeriod,
            'formationType': specimen.category,
            'chemicalComposition': _getChemicalComposition(specimen.category),
            'region': _getRegionFromLocation(specimen.location),
            'environment': _getEnvironment(specimen.formation),
          };
        }).toList();
        _filteredSpecimens = List.from(_allSpecimens);
        _isLoading = false;
      });
    });
  }

  String _getChemicalComposition(String category) {
    switch (category.toLowerCase()) {
      case 'igneous':
        return 'Silicate';
      case 'sedimentary':
        return 'Carbonate';
      case 'metamorphic':
        return 'Mixed Silicate';
      default:
        return 'Silicate';
    }
  }

  String _getRegionFromLocation(String location) {
    if (location.contains('Atlantic')) return 'Atlantic Ocean';
    if (location.contains('Pacific')) return 'Pacific Ocean';
    if (location.contains('Arctic')) return 'Arctic Ocean';
    if (location.contains('Caribbean')) return 'Caribbean Sea';
    return 'Atlantic Ocean';
  }

  String _getEnvironment(String formation) {
    switch (formation.toLowerCase()) {
      case 'hydrothermal deposit':
      case 'hydrothermal vent':
        return 'Hydrothermal';
      case 'mid-ocean ridge':
      case 'oceanic crust':
        return 'Volcanic';
      case 'abyssal plain':
        return 'Deep Marine';
      case 'seamount':
        return 'Seamount';
      default:
        return 'Marine';
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredSpecimens = _applyFilters(_allSpecimens);
      } else {
        _filteredSpecimens = _databaseService.searchSpecimens(query).map((specimen) {
          return {
            ...specimen,
            'firstLetter': specimen['name'].toString().substring(0, 1).toUpperCase(),
            'image': specimen['imageUrl'],
            'scientificName': specimen['name'],
            'geologicalPeriod': 'Recent',
            'formationType': specimen['category'],
            'chemicalComposition': _getChemicalComposition(specimen['category']),
            'region': _getRegionFromLocation(specimen['locations']?.first ?? 'Atlantic Ocean'),
            'environment': _getEnvironment(specimen['formation']),
          };
        }).toList();
        _filteredSpecimens = _applyFilters(_filteredSpecimens);
      }
    });
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> specimens) {
    if (_activeFilters.isEmpty) return specimens;

    return specimens.where((specimen) {
      for (final filterCategory in _activeFilters.entries) {
        final category = filterCategory.key;
        final selectedValues = filterCategory.value;

        bool matches = false;
        switch (category) {
          case 'Rock Types':
            matches = selectedValues.contains(specimen["formationType"]);
            break;
          case 'Categories':
            matches = selectedValues.contains(specimen["formationType"]);
            break;
          case 'Formation Environments':
            matches = selectedValues.contains(specimen["environment"]);
            break;
          case 'Geographic Regions':
            matches = selectedValues.contains(specimen["region"]);
            break;
          case 'Chemical Composition':
            matches = selectedValues.contains(specimen["chemicalComposition"]);
            break;
        }

        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  void _onLetterTap(String letter) {
    setState(() {
      _selectedLetter = letter;
    });

    final index = _filteredSpecimens
        .indexWhere((specimen) => (specimen["firstLetter"] as String) == letter);

    if (index != -1 && _scrollController.hasClients) {
      final itemHeight = 25.h + 12; // Card height + spacing
      _scrollController.animateTo(
        index * itemHeight / 2, // Divided by 2 for grid layout
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
            _filteredSpecimens = _applyFilters(_allSpecimens);
          });
        },
      ),
    );
  }

  void _removeFilter(String category) {
    setState(() {
      _activeFilters.remove(category);
      _filteredSpecimens = _applyFilters(_allSpecimens);
    });
  }

  void _onSpecimenTap(Map<String, dynamic> specimen) {
    Navigator.pushNamed(
      context,
      '/symbol-detail-view',
      arguments: specimen,
    );
  }

  void _onSpecimenLongPress(Map<String, dynamic> specimen) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildContextMenu(specimen),
    );
  }

  Widget _buildContextMenu(Map<String, dynamic> specimen) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'favorite_border',
              color: colorScheme.onSurface,
              size: 24,
            ),
            title: const Text('Add to Favorites'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${specimen['scientificName']} to favorites'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'compare',
              color: colorScheme.onSurface,
              size: 24,
            ),
            title: const Text('Compare Specimens'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Compare feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'share',
              color: colorScheme.onSurface,
              size: 24,
            ),
            title: const Text('Share Specimen'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing ${specimen['scientificName']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'camera_alt',
              color: colorScheme.onSurface,
              size: 24,
            ),
            title: const Text('Identify Similar'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/camera-capture');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    _loadDatabase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Rock Database',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/collection-manager'),
            icon: CustomIconWidget(
              iconName: 'collections',
              color: colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(colorScheme),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/camera-capture');
              break;
            case 1:
              Navigator.pushNamed(context, '/specimen-identification');
              break;
            case 2:
              // Already on database browser
              break;
            case 3:
              Navigator.pushNamed(context, '/field-notes');
              break;
            case 4:
              Navigator.pushNamed(context, '/collection-manager');
              break;
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading specimen database...'),
        ],
      ),
    );
  }

  Widget _buildMainContent(ColorScheme colorScheme) {
    return Column(
      children: [
        // Search and filter section
        Container(
          color: colorScheme.surface,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search rocks, minerals, formations...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(2.w),
                              child: CustomIconWidget(
                                iconName: 'clear',
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: _showFilterBottomSheet,
                          child: Container(
                            margin: EdgeInsets.only(right: 2.w),
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: _activeFilters.isNotEmpty
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: 'tune',
                              color: _activeFilters.isNotEmpty
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                ),
              ),

              // Active filter chips
              if (_activeFilters.isNotEmpty) ...[
                SizedBox(height: 2.h),
                SizedBox(
                  height: 5.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _activeFilters.length,
                    itemBuilder: (context, index) {
                      final entry = _activeFilters.entries.elementAt(index);
                      return FilterChipWidget(
                        label: entry.key,
                        count: entry.value.length,
                        onRemove: () => _removeFilter(entry.key),
                      );
                    },
                  ),
                ),
              ],

              // Database stats
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Database Statistics',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${_filteredSpecimens.length} of ${_allSpecimens.length} specimens',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    CustomIconWidget(
                      iconName: 'analytics',
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: _isSearching &&
                  _searchController.text.isNotEmpty &&
                  _filteredSpecimens.isEmpty
              ? _buildEmptySearchState()
              : _isSearching && _searchController.text.isEmpty
                  ? _buildSearchSuggestions()
                  : _buildSpecimenGrid(),
        ),
      ],
    );
  }

  Widget _buildSpecimenGrid() {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final specimen = _filteredSpecimens[index];
                      return SymbolCardWidget(
                        symbolData: specimen,
                        onTap: () => _onSpecimenTap(specimen),
                        onLongPress: () => _onSpecimenLongPress(specimen),
                      );
                    },
                    childCount: _filteredSpecimens.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: 10.h),
              ),
            ],
          ),
        ),

        // Alphabetical index
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: AlphabeticalIndexWidget(
            selectedLetter: _selectedLetter,
            onLetterTap: _onLetterTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSuggestions() {
    return SearchSuggestionsWidget(
      suggestions: _recentSearches,
      categoryShortcuts: _categoryShortcuts,
      onSuggestionTap: (suggestion) {
        _searchController.text = suggestion;
      },
      onCategoryTap: (category) {
        // Apply category filter based on category name
        setState(() {
          if (category == 'Marine Specimens') {
            _activeFilters['Formation Environments'] = ['Marine', 'Hydrothermal', 'Deep Marine'];
          } else {
            _activeFilters['Categories'] = [category];
          }
          _filteredSpecimens = _applyFilters(_allSpecimens);
        });
      },
    );
  }

  Widget _buildEmptySearchState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Specimens Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search terms or explore different categories of rock and mineral specimens.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _activeFilters.clear();
                      _filteredSpecimens = List.from(_allSpecimens);
                    });
                  },
                  child: const Text('Clear Search'),
                ),
                SizedBox(width: 2.w),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/camera-capture'),
                  child: const Text('Identify New'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}