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

/// Database Browser Screen for comprehensive exploration of geological specimens
/// and artifact symbol database with advanced filtering capabilities
class DatabaseBrowser extends StatefulWidget {
  const DatabaseBrowser({super.key});

  @override
  State<DatabaseBrowser> createState() => _DatabaseBrowserState();
}

class _DatabaseBrowserState extends State<DatabaseBrowser>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;

  String _selectedLetter = 'A';
  Map<String, List<String>> _activeFilters = {};
  List<Map<String, dynamic>> _filteredSymbols = [];
  List<Map<String, dynamic>> _allSymbols = [];
  bool _isSearching = false;
  bool _isLoading = false;

  // Mock database of geological symbols and artifacts
  final List<Map<String, dynamic>> _mockSymbols = [
    {
      "id": "1",
      "scientificName": "Quartz Crystal Formation",
      "geologicalPeriod": "Precambrian",
      "formationType": "Igneous",
      "image":
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop",
      "chemicalComposition": "Silicate",
      "region": "Atlantic Ocean",
      "environment": "Hydrothermal",
      "firstLetter": "Q",
    },
    {
      "id": "2",
      "scientificName": "Ammonite Fossil",
      "geologicalPeriod": "Jurassic",
      "formationType": "Sedimentary",
      "image":
          "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop",
      "chemicalComposition": "Carbonate",
      "region": "Mediterranean Sea",
      "environment": "Marine",
      "firstLetter": "A",
    },
    {
      "id": "3",
      "scientificName": "Basalt Column Structure",
      "geologicalPeriod": "Tertiary",
      "formationType": "Volcanic",
      "image":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop",
      "chemicalComposition": "Silicate",
      "region": "Pacific Ocean",
      "environment": "Volcanic",
      "firstLetter": "B",
    },
    {
      "id": "4",
      "scientificName": "Coral Reef Formation",
      "geologicalPeriod": "Quaternary",
      "formationType": "Organic",
      "image":
          "https://images.unsplash.com/photo-1583212292454-1fe6229603b7?w=400&h=300&fit=crop",
      "chemicalComposition": "Carbonate",
      "region": "Caribbean Sea",
      "environment": "Marine",
      "firstLetter": "C",
    },
    {
      "id": "5",
      "scientificName": "Granite Intrusion",
      "geologicalPeriod": "Precambrian",
      "formationType": "Plutonic",
      "image":
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop",
      "chemicalComposition": "Silicate",
      "region": "North Sea",
      "environment": "Continental",
      "firstLetter": "G",
    },
    {
      "id": "6",
      "scientificName": "Limestone Cave Formation",
      "geologicalPeriod": "Carboniferous",
      "formationType": "Chemical",
      "image":
          "https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400&h=300&fit=crop",
      "chemicalComposition": "Carbonate",
      "region": "Mediterranean Sea",
      "environment": "Marine",
      "firstLetter": "L",
    },
    {
      "id": "7",
      "scientificName": "Obsidian Glass Formation",
      "geologicalPeriod": "Quaternary",
      "formationType": "Volcanic",
      "image":
          "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop",
      "chemicalComposition": "Silicate",
      "region": "Pacific Ocean",
      "environment": "Volcanic",
      "firstLetter": "O",
    },
    {
      "id": "8",
      "scientificName": "Sandstone Layers",
      "geologicalPeriod": "Triassic",
      "formationType": "Clastic",
      "image":
          "https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop",
      "chemicalComposition": "Silicate",
      "region": "Red Sea",
      "environment": "Desert",
      "firstLetter": "S",
    },
  ];

  final List<String> _recentSearches = [
    "Quartz formations",
    "Jurassic fossils",
    "Volcanic rocks",
    "Marine sediments",
    "Coral structures",
  ];

  final List<Map<String, dynamic>> _categoryShortcuts = [
    {
      "name": "Rock Types",
      "icon": Icons.landscape,
      "count": 156,
    },
    {
      "name": "Marine Life",
      "icon": Icons.waves,
      "count": 89,
    },
    {
      "name": "Fossils",
      "icon": Icons.local_florist,
      "count": 234,
    },
    {
      "name": "Artifacts",
      "icon": Icons.museum,
      "count": 67,
    },
    {
      "name": "Minerals",
      "icon": Icons.science,
      "count": 198,
    },
    {
      "name": "Formations",
      "icon": Icons.category,
      "count": 145,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _allSymbols = List.from(_mockSymbols);
    _filteredSymbols = List.from(_mockSymbols);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredSymbols = _applyFilters(_allSymbols);
      } else {
        _filteredSymbols = _allSymbols.where((symbol) {
          final scientificName =
              (symbol["scientificName"] as String).toLowerCase();
          final geologicalPeriod =
              (symbol["geologicalPeriod"] as String).toLowerCase();
          final formationType =
              (symbol["formationType"] as String).toLowerCase();

          return scientificName.contains(query) ||
              geologicalPeriod.contains(query) ||
              formationType.contains(query);
        }).toList();
        _filteredSymbols = _applyFilters(_filteredSymbols);
      }
    });
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> symbols) {
    if (_activeFilters.isEmpty) return symbols;

    return symbols.where((symbol) {
      for (final filterCategory in _activeFilters.entries) {
        final category = filterCategory.key;
        final selectedValues = filterCategory.value;

        bool matches = false;
        switch (category) {
          case 'Rock Types':
            matches = selectedValues.contains(symbol["formationType"]);
            break;
          case 'Geological Periods':
            matches = selectedValues.contains(symbol["geologicalPeriod"]);
            break;
          case 'Formation Environments':
            matches = selectedValues.contains(symbol["environment"]);
            break;
          case 'Geographic Regions':
            matches = selectedValues.contains(symbol["region"]);
            break;
          case 'Chemical Composition':
            matches = selectedValues.contains(symbol["chemicalComposition"]);
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

    final index = _filteredSymbols
        .indexWhere((symbol) => (symbol["firstLetter"] as String) == letter);

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
            _filteredSymbols = _applyFilters(_allSymbols);
          });
        },
      ),
    );
  }

  void _removeFilter(String category) {
    setState(() {
      _activeFilters.remove(category);
      _filteredSymbols = _applyFilters(_allSymbols);
    });
  }

  void _onSymbolTap(Map<String, dynamic> symbol) {
    Navigator.pushNamed(
      context,
      '/symbol-detail-view',
      arguments: symbol,
    );
  }

  void _onSymbolLongPress(Map<String, dynamic> symbol) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildContextMenu(symbol),
    );
  }

  Widget _buildContextMenu(Map<String, dynamic> symbol) {
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
            title: Text('Add to Favorites'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'compare',
              color: colorScheme.onSurface,
              size: 24,
            ),
            title: Text('Compare'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'share',
              color: colorScheme.onSurface,
              size: 24,
            ),
            title: Text('Share'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'map',
              color: colorScheme.onSurface,
              size: 24,
            ),
            title: Text('View Formation Map'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate database refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _filteredSymbols = _applyFilters(_allSymbols);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky header with search and filters
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
                        hintText: 'Search specimens, periods, formations...',
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
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: () {
                                // Voice search functionality would go here
                              },
                              child: Padding(
                                padding: EdgeInsets.all(2.w),
                                child: CustomIconWidget(
                                  iconName: 'mic',
                                  color: colorScheme.primary,
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
                                      : colorScheme.onSurface
                                          .withValues(alpha: 0.6),
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
                ],
              ),
            ),

            // Main content
            Expanded(
              child: _isSearching &&
                      _searchController.text.isNotEmpty &&
                      _filteredSymbols.isEmpty
                  ? _buildEmptySearchState()
                  : _isSearching && _searchController.text.isEmpty
                      ? _buildSearchSuggestions()
                      : _buildSymbolGrid(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2, // Database tab active
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

  Widget _buildSymbolGrid() {
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
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 2.h,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final symbol = _filteredSymbols[index];
                      return SymbolCardWidget(
                        symbolData: symbol,
                        onTap: () => _onSymbolTap(symbol),
                        onLongPress: () => _onSymbolLongPress(symbol),
                      );
                    },
                    childCount: _filteredSymbols.length,
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

        // Loading indicator
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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
        // Apply category filter
        setState(() {
          _activeFilters[category] = [category];
          _filteredSymbols = _applyFilters(_allSymbols);
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
              'No Results Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search terms or filters to find what you\'re looking for.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _activeFilters.clear();
                  _filteredSymbols = List.from(_allSymbols);
                });
              },
              child: Text('Clear Search & Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
