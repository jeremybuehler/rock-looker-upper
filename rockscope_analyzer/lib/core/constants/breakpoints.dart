/// Responsive breakpoint system for RockScope Analyzer
/// 
/// Provides consistent breakpoints and responsive utilities across the app
/// Mobile-first design approach with adaptive layouts
library;

import 'package:flutter/material.dart';

/// Responsive breakpoint constants
class Breakpoints {
  /// Mobile devices (0 - 768px)
  /// Primary target - optimized for touch interactions
  static const double mobile = 768;
  
  /// Tablet devices (768 - 1024px)
  /// Hybrid touch/mouse interactions
  static const double tablet = 1024;
  
  /// Desktop devices (1024 - 1440px)
  /// Mouse-first interactions with keyboard shortcuts
  static const double desktop = 1440;
  
  /// Large desktop (1440px+)
  /// Wide screen layouts with enhanced content density
  static const double largeDesktop = 1440;
  
  /// Minimum touch target size (44px) per accessibility guidelines
  static const double minTouchTarget = 44.0;
  
  /// Recommended touch target size for better usability
  static const double recommendedTouchTarget = 48.0;
}

/// Device type enumeration for layout decisions
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// Responsive helper utilities
class ResponsiveHelper {
  /// Get current device type based on screen width
  static DeviceType getDeviceType(double width) {
    if (width >= Breakpoints.largeDesktop) return DeviceType.largeDesktop;
    if (width >= Breakpoints.desktop) return DeviceType.desktop;
    if (width >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }
  
  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoints.mobile;
  }
  
  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.mobile && width < Breakpoints.desktop;
  }
  
  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= Breakpoints.desktop && width < Breakpoints.largeDesktop;
  }
  
  /// Check if current screen is large desktop
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoints.largeDesktop;
  }
  
  /// Get responsive columns based on screen size
  /// Mobile: 1-2 columns, Tablet: 2-3 columns, Desktop: 3-4 columns
  static int getResponsiveColumns(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
    int largeDesktopColumns = 4,
  }) {
    final deviceType = getDeviceType(MediaQuery.of(context).size.width);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobileColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.desktop:
        return desktopColumns;
      case DeviceType.largeDesktop:
        return largeDesktopColumns;
    }
  }
  
  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context, {
    double mobileSpacing = 16.0,
    double tabletSpacing = 24.0,
    double desktopSpacing = 32.0,
  }) {
    if (isMobile(context)) return mobileSpacing;
    if (isTablet(context)) return tabletSpacing;
    return desktopSpacing;
  }
  
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    mobile ??= const EdgeInsets.all(16.0);
    tablet ??= const EdgeInsets.all(24.0);
    desktop ??= const EdgeInsets.all(32.0);
    
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }
}

/// Responsive widget builder for adaptive layouts
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  
  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(
      MediaQuery.of(context).size.width,
    );
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Layout constraints for different screen sizes
class LayoutConstraints {
  /// Maximum content width for readability
  static const double maxContentWidth = 1200.0;
  
  /// Maximum form width for better UX
  static const double maxFormWidth = 600.0;
  
  /// Maximum card width in grid layouts
  static const double maxCardWidth = 400.0;
  
  /// Navigation rail width for tablet/desktop
  static const double navigationRailWidth = 72.0;
  
  /// Extended navigation rail width
  static const double extendedNavigationRailWidth = 256.0;
  
  /// Side sheet width for tablets
  static const double sideSheetWidth = 320.0;
  
  /// Dialog width for desktop
  static const double desktopDialogWidth = 560.0;
}

/// Responsive text scaling
class ResponsiveText {
  /// Get responsive font size multiplier
  static double getTextScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= Breakpoints.largeDesktop) return 1.1;
    if (width >= Breakpoints.desktop) return 1.0;
    if (width >= Breakpoints.tablet) return 0.95;
    return 0.9;
  }
  
  /// Apply responsive scaling to text style
  static TextStyle? scaleTextStyle(BuildContext context, TextStyle? style) {
    if (style == null) return null;
    
    final scaleFactor = getTextScaleFactor(context);
    return style.copyWith(
      fontSize: (style.fontSize ?? 14.0) * scaleFactor,
    );
  }
}