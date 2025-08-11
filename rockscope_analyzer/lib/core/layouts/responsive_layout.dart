/// Responsive layout system for RockScope Analyzer
/// 
/// Provides adaptive layouts that respond to different screen sizes
/// and interaction patterns (touch vs mouse)
library;

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import '../constants/breakpoints.dart';
import '../../widgets/custom_icon_widget.dart';

/// Main responsive layout wrapper for the entire app
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.navigationItems = const [],
    this.currentIndex = 0,
    this.onNavigationChanged,
    this.floatingActionButton,
    this.appBar,
    this.drawer,
  });

  final Widget child;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int>? onNavigationChanged;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    // For now, let's simplify and just return the child with basic responsive layout
    // This avoids the complex AdaptiveScaffold configuration that was causing issues
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      body: child,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: navigationItems.isNotEmpty ? BottomNavigationBar(
        items: navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: CustomIconWidget(iconName: item.icon, size: 24),
                  activeIcon: CustomIconWidget(iconName: item.selectedIcon, size: 24),
                  label: item.label,
                ))
            .toList(),
        currentIndex: currentIndex,
        onTap: onNavigationChanged,
        type: BottomNavigationBarType.fixed,
      ) : null,
    );
  }
}

/// Navigation item model
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });

  final String icon;
  final String selectedIcon;
  final String label;
  final String? badge;
}

/// Mobile layout with bottom navigation
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.child,
    required this.navigationItems,
    required this.currentIndex,
    this.onNavigationChanged,
    this.floatingActionButton,
  });

  final Widget child;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int>? onNavigationChanged;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(child: child),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: navigationItems.isNotEmpty ? Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, navigationItems.length - 1),
          onTap: onNavigationChanged,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          backgroundColor: theme.colorScheme.surface,
          elevation: 0,
          items: navigationItems.map((item) {
            final index = navigationItems.indexOf(item);
            final isSelected = index == currentIndex;
            
            return BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: isSelected ? item.selectedIcon : item.icon,
                size: 24,
                color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              label: item.label,
              backgroundColor: theme.colorScheme.surface,
            );
          }).toList(),
        ),
      ) : null,
    );
  }
}

/// Tablet layout with navigation rail
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.child,
    required this.navigationItems,
    required this.currentIndex,
    this.onNavigationChanged,
    this.floatingActionButton,
  });

  final Widget child;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int>? onNavigationChanged;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Row(
        children: [
          if (navigationItems.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationRail(
                selectedIndex: currentIndex.clamp(0, navigationItems.length - 1),
                onDestinationSelected: onNavigationChanged,
                labelType: NavigationRailLabelType.selected,
                backgroundColor: theme.colorScheme.surface,
                destinations: navigationItems.map((item) {
                  final index = navigationItems.indexOf(item);
                  final isSelected = index == currentIndex;
                  
                  return NavigationRailDestination(
                    icon: CustomIconWidget(
                      iconName: item.icon,
                      size: 24,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    selectedIcon: CustomIconWidget(
                      iconName: item.selectedIcon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(item.label),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: SafeArea(child: child),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Desktop layout with extended navigation rail
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.child,
    required this.navigationItems,
    required this.currentIndex,
    this.onNavigationChanged,
    this.floatingActionButton,
  });

  final Widget child;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int>? onNavigationChanged;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Row(
        children: [
          if (navigationItems.isNotEmpty)
            Container(
              width: LayoutConstraints.extendedNavigationRailWidth,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: NavigationRail(
                selectedIndex: currentIndex.clamp(0, navigationItems.length - 1),
                onDestinationSelected: onNavigationChanged,
                labelType: NavigationRailLabelType.all,
                extended: true,
                backgroundColor: theme.colorScheme.surface,
                destinations: navigationItems.map((item) {
                  final index = navigationItems.indexOf(item);
                  final isSelected = index == currentIndex;
                  
                  return NavigationRailDestination(
                    icon: CustomIconWidget(
                      iconName: item.icon,
                      size: 24,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    selectedIcon: CustomIconWidget(
                      iconName: item.selectedIcon,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(item.label),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: SafeArea(child: child),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Responsive content wrapper with max width constraints
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? LayoutConstraints.maxContentWidth,
        ),
        child: Padding(
          padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
          child: child,
        ),
      ),
    );
  }
}

/// Responsive grid for displaying collections of items
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.maxCrossAxisExtent = 300.0,
    this.childAspectRatio = 1.0,
  });

  final List<Widget> children;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double maxCrossAxisExtent;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive dialog for different screen sizes
class ResponsiveDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    final theme = Theme.of(context);
    
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ResponsiveBuilder(
        mobile: AlertDialog(
          title: title != null ? Text(title) : null,
          content: child,
          actions: actions,
        ),
        tablet: Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: LayoutConstraints.desktopDialogWidth,
              maxHeight: 600,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
                if (actions != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}