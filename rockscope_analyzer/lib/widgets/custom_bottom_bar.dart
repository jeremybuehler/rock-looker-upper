import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Bottom Navigation Bar implementing Scientific Precision Minimalism
/// Optimized for field research workflows with clear iconography and
/// accessibility features for outdoor use
class CustomBottomBar extends StatefulWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when item is tapped
  final ValueChanged<int> onTap;

  /// Type of bottom navigation bar
  final BottomNavigationBarType type;

  /// Background color override
  final Color? backgroundColor;

  /// Selected item color override
  final Color? selectedItemColor;

  /// Unselected item color override
  final Color? unselectedItemColor;

  /// Elevation override
  final double elevation;

  /// Whether to show labels
  final bool showLabels;

  /// Variant of the bottom bar
  final CustomBottomBarVariant variant;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.type = BottomNavigationBarType.fixed,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.showLabels = true,
    this.variant = CustomBottomBarVariant.standard,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      _getNavigationItems().length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start animation for current index
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset previous animation
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on variant and theme
    Color effectiveBackgroundColor;
    Color effectiveSelectedColor;
    Color effectiveUnselectedColor;

    switch (widget.variant) {
      case CustomBottomBarVariant.standard:
        effectiveBackgroundColor =
            widget.backgroundColor ?? colorScheme.surface;
        effectiveSelectedColor =
            widget.selectedItemColor ?? colorScheme.primary;
        effectiveUnselectedColor = widget.unselectedItemColor ??
            (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
        break;
      case CustomBottomBarVariant.floating:
        effectiveBackgroundColor =
            widget.backgroundColor ?? colorScheme.surface;
        effectiveSelectedColor =
            widget.selectedItemColor ?? colorScheme.primary;
        effectiveUnselectedColor = widget.unselectedItemColor ??
            (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
        break;
      case CustomBottomBarVariant.minimal:
        effectiveBackgroundColor = widget.backgroundColor ?? Colors.transparent;
        effectiveSelectedColor =
            widget.selectedItemColor ?? colorScheme.primary;
        effectiveUnselectedColor = widget.unselectedItemColor ??
            (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
        break;
    }

    if (widget.variant == CustomBottomBarVariant.floating) {
      return _buildFloatingBottomBar(
        context,
        effectiveBackgroundColor,
        effectiveSelectedColor,
        effectiveUnselectedColor,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        boxShadow: widget.variant != CustomBottomBarVariant.minimal
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: widget.elevation,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(
              context,
              effectiveSelectedColor,
              effectiveUnselectedColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(
    BuildContext context,
    Color backgroundColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildNavigationItems(
                  context,
                  selectedColor,
                  unselectedColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final items = _getNavigationItems();

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == widget.currentIndex;

      return Expanded(
        child: GestureDetector(
          onTap: () {
            widget.onTap(index);
            _navigateToRoute(context, index);
          },
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: 24,
                        color: isSelected ? selectedColor : unselectedColor,
                      ),
                    ),
                    if (widget.showLabels) ...[
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected ? selectedColor : unselectedColor,
                          letterSpacing: 0.4,
                        ),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  List<_NavigationItem> _getNavigationItems() {
    return [
      _NavigationItem(
        icon: Icons.camera_alt_outlined,
        selectedIcon: Icons.camera_alt,
        label: 'Capture',
        route: '/camera-capture',
      ),
      _NavigationItem(
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        label: 'Identify',
        route: '/specimen-identification',
      ),
      _NavigationItem(
        icon: Icons.library_books_outlined,
        selectedIcon: Icons.library_books,
        label: 'Database',
        route: '/database-browser',
      ),
      _NavigationItem(
        icon: Icons.note_outlined,
        selectedIcon: Icons.note,
        label: 'Notes',
        route: '/field-notes',
      ),
      _NavigationItem(
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        label: 'Collections',
        route: '/collection-manager',
      ),
    ];
  }

  void _navigateToRoute(BuildContext context, int index) {
    final items = _getNavigationItems();
    if (index < items.length) {
      Navigator.pushNamed(context, items[index].route);
    }
  }
}

/// Internal class to represent navigation items
class _NavigationItem {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.route,
  });
}

/// Enum defining different variants of the CustomBottomBar
enum CustomBottomBarVariant {
  /// Standard bottom bar with surface background
  standard,

  /// Floating bottom bar with rounded corners
  floating,

  /// Minimal bottom bar with transparent background
  minimal,
}
