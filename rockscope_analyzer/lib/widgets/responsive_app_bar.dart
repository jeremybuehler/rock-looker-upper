/// Responsive app bar that adapts to different screen sizes
/// 
/// Provides consistent header experience across mobile, tablet, and desktop
library;

import 'package:flutter/material.dart';
import '../core/app_export.dart';

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ResponsiveAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.centerTitle,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.flexibleSpace,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool? centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize {
    return Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return AppBar(
      title: title,
      leading: leading,
      actions: _buildResponsiveActions(context),
      centerTitle: centerTitle ?? isMobile,
      elevation: elevation ?? (isDesktop ? 1 : 2),
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      automaticallyImplyLeading: automaticallyImplyLeading,
      toolbarHeight: isDesktop ? 64 : kToolbarHeight,
      titleSpacing: isDesktop ? 32 : NavigationToolbar.kMiddleSpacing,
      
      // Desktop-specific styling
      shape: isDesktop
          ? Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            )
          : null,
    );
  }

  List<Widget>? _buildResponsiveActions(BuildContext context) {
    if (actions == null) return null;
    
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    // Add more spacing between actions on desktop
    if (isDesktop && actions!.isNotEmpty) {
      final spacedActions = <Widget>[];
      for (int i = 0; i < actions!.length; i++) {
        spacedActions.add(actions![i]);
        if (i < actions!.length - 1) {
          spacedActions.add(const SizedBox(width: 8));
        }
      }
      spacedActions.add(const SizedBox(width: 16)); // Trailing space
      return spacedActions;
    }
    
    return actions;
  }
}

/// Search app bar for responsive search functionality
class ResponsiveSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const ResponsiveSearchAppBar({
    super.key,
    required this.onSearch,
    this.initialQuery = '',
    this.hintText = 'Search...',
    this.leading,
    this.actions,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
  });

  final ValueChanged<String> onSearch;
  final String initialQuery;
  final String hintText;
  final Widget? leading;
  final List<Widget>? actions;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ResponsiveSearchAppBar> createState() => _ResponsiveSearchAppBarState();
}

class _ResponsiveSearchAppBarState extends State<ResponsiveSearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return AppBar(
      leading: widget.leading,
      title: Container(
        height: isDesktop ? 48 : 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onSearch,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(
              Icons.search,
              size: isDesktop ? 24 : 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: isDesktop ? 24 : 20,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onSearch('');
                    },
                    tooltip: 'Clear search',
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 16 : 12,
              vertical: isDesktop ? 14 : 10,
            ),
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
      ),
      actions: widget.actions,
      elevation: widget.elevation ?? (isDesktop ? 1 : 2),
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: widget.foregroundColor ?? theme.colorScheme.onSurface,
      toolbarHeight: isDesktop ? 64 : kToolbarHeight,
      
      // Desktop-specific styling
      shape: isDesktop
          ? Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            )
          : null,
    );
  }
}

/// Responsive floating action button that adapts size and position
class ResponsiveFloatingActionButton extends StatelessWidget {
  const ResponsiveFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final Widget? label;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    // Show extended FAB on desktop/tablet with label
    if ((isDesktop || ResponsiveHelper.isTablet(context)) && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: icon,
        label: label!,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: isDesktop ? 3 : 6,
      );
    }
    
    // Standard FAB for mobile or when no label provided
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: isMobile ? 6 : 3,
      child: icon,
    );
  }
}

/// Responsive bottom sheet that adapts to screen size
class ResponsiveBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    // Show as dialog on desktop
    if (isDesktop) {
      return ResponsiveDialog.show<T>(
        context: context,
        child: child,
        title: title,
        barrierDismissible: isDismissible,
      );
    }
    
    // Show as bottom sheet on mobile/tablet
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            Flexible(child: child),
          ],
        ),
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
    );
  }
}