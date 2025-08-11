import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Scientific Precision Minimalism
/// Optimized for field research applications with clear visual hierarchy
/// and outdoor visibility considerations
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// List of action widgets to display on the right
  final List<Widget>? actions;

  /// Whether to show the back button automatically
  final bool automaticallyImplyLeading;

  /// Background color override
  final Color? backgroundColor;

  /// Foreground color override
  final Color? foregroundColor;

  /// Elevation override
  final double? elevation;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  /// Variant of the app bar
  final CustomAppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.bottom,
    this.variant = CustomAppBarVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on variant and theme
    Color effectiveBackgroundColor;
    Color effectiveForegroundColor;
    double effectiveElevation;

    switch (variant) {
      case CustomAppBarVariant.standard:
        effectiveBackgroundColor = backgroundColor ??
            theme.appBarTheme.backgroundColor ??
            colorScheme.surface;
        effectiveForegroundColor = foregroundColor ??
            theme.appBarTheme.foregroundColor ??
            colorScheme.onSurface;
        effectiveElevation = elevation ?? theme.appBarTheme.elevation ?? 2.0;
        break;
      case CustomAppBarVariant.transparent:
        effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
        effectiveElevation = elevation ?? 0.0;
        break;
      case CustomAppBarVariant.primary:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.primary;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onPrimary;
        effectiveElevation = elevation ?? 4.0;
        break;
      case CustomAppBarVariant.surface:
        effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
        effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;
        effectiveElevation = elevation ?? 1.0;
        break;
    }

    return AppBar(
      title: _buildTitle(context, effectiveForegroundColor),
      leading: leading,
      actions: _buildActions(context, effectiveForegroundColor),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: effectiveElevation,
      centerTitle: centerTitle,
      bottom: bottom,
      surfaceTintColor: Colors.transparent,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.2),
      toolbarHeight: subtitle != null ? 72.0 : 56.0,
      titleSpacing: 16.0,
      leadingWidth: 56.0,
      toolbarTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: effectiveForegroundColor,
      ),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: effectiveForegroundColor,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(
        color: effectiveForegroundColor,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: effectiveForegroundColor,
        size: 24,
      ),
    );
  }

  /// Builds the title widget with optional subtitle
  Widget _buildTitle(BuildContext context, Color foregroundColor) {
    if (subtitle == null) {
      return Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: foregroundColor,
          letterSpacing: 0.15,
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: foregroundColor,
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle!,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: foregroundColor.withValues(alpha: 0.7),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  /// Builds the actions with proper spacing and scientific context
  List<Widget>? _buildActions(BuildContext context, Color foregroundColor) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          onPressed: action.onPressed,
          icon: action.icon,
          color: foregroundColor,
          iconSize: 24,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        );
      }
      return action;
    }).toList();
  }

  @override
  Size get preferredSize {
    double height = 56.0;
    if (subtitle != null) height = 72.0;
    if (bottom != null) height += bottom!.preferredSize.height;
    return Size.fromHeight(height);
  }

  /// Factory constructor for camera capture screen
  factory CustomAppBar.cameraCapture({
    Key? key,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Camera Capture',
      subtitle: 'Specimen Documentation',
      variant: CustomAppBarVariant.transparent,
      centerTitle: true,
      actions: actions ??
          [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.flash_auto),
              tooltip: 'Flash Settings',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings),
              tooltip: 'Camera Settings',
            ),
          ],
    );
  }

  /// Factory constructor for specimen identification screen
  factory CustomAppBar.specimenIdentification({
    Key? key,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Specimen ID',
      subtitle: 'AI-Powered Analysis',
      variant: CustomAppBarVariant.standard,
      actions: actions ??
          [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
              tooltip: 'Search Database',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border),
              tooltip: 'Save Results',
            ),
          ],
    );
  }

  /// Factory constructor for database browser screen
  factory CustomAppBar.databaseBrowser({
    Key? key,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Species Database',
      subtitle: 'Scientific Reference',
      variant: CustomAppBarVariant.standard,
      actions: actions ??
          [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter Results',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.sort),
              tooltip: 'Sort Options',
            ),
          ],
    );
  }

  /// Factory constructor for field notes screen
  factory CustomAppBar.fieldNotes({
    Key? key,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Field Notes',
      subtitle: 'Research Documentation',
      variant: CustomAppBarVariant.standard,
      actions: actions ??
          [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
              tooltip: 'New Note',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.sync),
              tooltip: 'Sync Status',
            ),
          ],
    );
  }

  /// Factory constructor for collection manager screen
  factory CustomAppBar.collectionManager({
    Key? key,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Collections',
      subtitle: 'Specimen Management',
      variant: CustomAppBarVariant.standard,
      actions: actions ??
          [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.cloud_upload),
              tooltip: 'Upload Data',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
              tooltip: 'More Options',
            ),
          ],
    );
  }
}

/// Enum defining different variants of the CustomAppBar
enum CustomAppBarVariant {
  /// Standard app bar with surface background
  standard,

  /// Transparent app bar for overlay scenarios
  transparent,

  /// Primary colored app bar for emphasis
  primary,

  /// Surface app bar with minimal elevation
  surface,
}
