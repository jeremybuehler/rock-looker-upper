import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Tab Bar implementing Scientific Precision Minimalism
/// Optimized for scientific categorization and data organization
/// with clear visual hierarchy and accessibility features
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// List of tab labels
  final List<String> tabs;

  /// Current selected tab index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int> onTap;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Tab alignment for scrollable tabs
  final TabAlignment tabAlignment;

  /// Indicator color override
  final Color? indicatorColor;

  /// Label color override
  final Color? labelColor;

  /// Unselected label color override
  final Color? unselectedLabelColor;

  /// Background color override
  final Color? backgroundColor;

  /// Indicator weight
  final double indicatorWeight;

  /// Indicator padding
  final EdgeInsetsGeometry indicatorPadding;

  /// Tab variant
  final CustomTabBarVariant variant;

  /// Optional icons for tabs
  final List<IconData>? icons;

  /// Whether to show icons
  final bool showIcons;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.isScrollable = false,
    this.tabAlignment = TabAlignment.center,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.backgroundColor,
    this.indicatorWeight = 2.0,
    this.indicatorPadding = EdgeInsets.zero,
    this.variant = CustomTabBarVariant.standard,
    this.icons,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on variant and theme
    Color effectiveIndicatorColor;
    Color effectiveLabelColor;
    Color effectiveUnselectedLabelColor;
    Color effectiveBackgroundColor;

    switch (variant) {
      case CustomTabBarVariant.standard:
        effectiveIndicatorColor = indicatorColor ?? colorScheme.primary;
        effectiveLabelColor = labelColor ?? colorScheme.primary;
        effectiveUnselectedLabelColor = unselectedLabelColor ??
            (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
        effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
        break;
      case CustomTabBarVariant.primary:
        effectiveIndicatorColor = indicatorColor ?? colorScheme.onPrimary;
        effectiveLabelColor = labelColor ?? colorScheme.onPrimary;
        effectiveUnselectedLabelColor = unselectedLabelColor ??
            colorScheme.onPrimary.withValues(alpha: 0.7);
        effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
        break;
      case CustomTabBarVariant.surface:
        effectiveIndicatorColor = indicatorColor ?? colorScheme.primary;
        effectiveLabelColor = labelColor ?? colorScheme.onSurface;
        effectiveUnselectedLabelColor = unselectedLabelColor ??
            (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
        effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
        break;
      case CustomTabBarVariant.outlined:
        effectiveIndicatorColor = indicatorColor ?? Colors.transparent;
        effectiveLabelColor = labelColor ?? colorScheme.primary;
        effectiveUnselectedLabelColor = unselectedLabelColor ??
            (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280));
        effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: variant == CustomTabBarVariant.outlined
            ? Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              )
            : null,
      ),
      child: TabBar(
        tabs: _buildTabs(
            context, effectiveLabelColor, effectiveUnselectedLabelColor),
        isScrollable: isScrollable,
        tabAlignment: tabAlignment,
        indicatorColor: effectiveIndicatorColor,
        labelColor: effectiveLabelColor,
        unselectedLabelColor: effectiveUnselectedLabelColor,
        indicatorWeight: indicatorWeight,
        indicatorPadding: indicatorPadding,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicator: _buildIndicator(context, effectiveIndicatorColor),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onTap: onTap,
      ),
    );
  }

  List<Widget> _buildTabs(
    BuildContext context,
    Color labelColor,
    Color unselectedLabelColor,
  ) {
    return tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final label = entry.value;
      final isSelected = index == currentIndex;
      final hasIcon = showIcons && icons != null && index < icons!.length;

      if (variant == CustomTabBarVariant.outlined) {
        return _buildOutlinedTab(
          context,
          label,
          isSelected,
          labelColor,
          unselectedLabelColor,
          hasIcon ? icons![index] : null,
        );
      }

      if (hasIcon) {
        return Tab(
          icon: Icon(
            icons![index],
            size: 20,
          ),
          text: label,
          iconMargin: const EdgeInsets.only(bottom: 4),
        );
      }

      return Tab(text: label);
    }).toList();
  }

  Widget _buildOutlinedTab(
    BuildContext context,
    String label,
    bool isSelected,
    Color labelColor,
    Color unselectedLabelColor,
    IconData? icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? labelColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? labelColor
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? labelColor : unselectedLabelColor,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? labelColor : unselectedLabelColor,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Decoration? _buildIndicator(BuildContext context, Color indicatorColor) {
    if (variant == CustomTabBarVariant.outlined) {
      return null;
    }

    return UnderlineTabIndicator(
      borderSide: BorderSide(
        color: indicatorColor,
        width: indicatorWeight,
      ),
      insets: indicatorPadding,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);

  /// Factory constructor for specimen classification tabs
  factory CustomTabBar.specimenClassification({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const [
        'Marine Life',
        'Geology',
        'Flora',
        'Artifacts',
        'Unknown',
      ],
      icons: const [
        Icons.waves,
        Icons.landscape,
        Icons.local_florist,
        Icons.museum,
        Icons.help_outline,
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomTabBarVariant.standard,
      showIcons: true,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
    );
  }

  /// Factory constructor for database filter tabs
  factory CustomTabBar.databaseFilter({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const [
        'All Species',
        'Recent',
        'Favorites',
        'Local',
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomTabBarVariant.outlined,
      isScrollable: false,
    );
  }

  /// Factory constructor for field notes categories
  factory CustomTabBar.fieldNotesCategories({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const [
        'Observations',
        'Measurements',
        'Sketches',
        'GPS Data',
        'Weather',
      ],
      icons: const [
        Icons.visibility,
        Icons.straighten,
        Icons.draw,
        Icons.location_on,
        Icons.wb_sunny,
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomTabBarVariant.surface,
      showIcons: true,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
    );
  }

  /// Factory constructor for collection status tabs
  factory CustomTabBar.collectionStatus({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const [
        'Active',
        'Pending',
        'Synced',
        'Archived',
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomTabBarVariant.standard,
      isScrollable: false,
    );
  }

  /// Factory constructor for identification confidence tabs
  factory CustomTabBar.identificationConfidence({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomTabBar(
      key: key,
      tabs: const [
        'High (90%+)',
        'Medium (70-89%)',
        'Low (<70%)',
        'Manual Review',
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      variant: CustomTabBarVariant.outlined,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
    );
  }
}

/// Enum defining different variants of the CustomTabBar
enum CustomTabBarVariant {
  /// Standard tab bar with underline indicator
  standard,

  /// Primary colored tab bar for emphasis
  primary,

  /// Surface tab bar with minimal styling
  surface,

  /// Outlined tab bar with pill-shaped tabs
  outlined,
}
