/// Touch-optimized widgets for responsive mobile-first design
/// 
/// Provides touch-friendly interactions with proper sizing and feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_export.dart';

/// Touch-optimized button with proper sizing and haptic feedback
class TouchOptimizedButton extends StatelessWidget {
  const TouchOptimizedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.type = TouchButtonType.elevated,
    this.size = TouchButtonSize.medium,
    this.fullWidth = false,
    this.loading = false,
    this.hapticFeedback = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final TouchButtonType type;
  final TouchButtonSize size;
  final bool fullWidth;
  final bool loading;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    final buttonHeight = _getButtonHeight(context);
    final buttonPadding = _getButtonPadding(context);
    
    Widget button;
    
    // Create loading indicator if needed
    final buttonChild = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: type == TouchButtonType.elevated || type == TouchButtonType.filled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          )
        : child;
    
    final effectiveStyle = style ?? _getDefaultStyle(context);
    
    switch (type) {
      case TouchButtonType.elevated:
        button = ElevatedButton(
          onPressed: loading ? null : _onPressedWithHaptic,
          style: effectiveStyle,
          child: buttonChild,
        );
        break;
        
      case TouchButtonType.filled:
        button = FilledButton(
          onPressed: loading ? null : _onPressedWithHaptic,
          style: effectiveStyle,
          child: buttonChild,
        );
        break;
        
      case TouchButtonType.outlined:
        button = OutlinedButton(
          onPressed: loading ? null : _onPressedWithHaptic,
          style: effectiveStyle,
          child: buttonChild,
        );
        break;
        
      case TouchButtonType.text:
        button = TextButton(
          onPressed: loading ? null : _onPressedWithHaptic,
          style: effectiveStyle,
          child: buttonChild,
        );
        break;
    }
    
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
  
  void _onPressedWithHaptic() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onPressed?.call();
  }
  
  double _getButtonHeight(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    switch (size) {
      case TouchButtonSize.small:
        return isDesktop ? 36 : 32;
      case TouchButtonSize.medium:
        return isDesktop ? 48 : Breakpoints.minTouchTarget;
      case TouchButtonSize.large:
        return isDesktop ? 56 : Breakpoints.recommendedTouchTarget;
    }
  }
  
  EdgeInsets _getButtonPadding(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    switch (size) {
      case TouchButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: isDesktop ? 12 : 8,
          vertical: 0,
        );
      case TouchButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: 0,
        );
      case TouchButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 20,
          vertical: 0,
        );
    }
  }
  
  ButtonStyle _getDefaultStyle(BuildContext context) {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size.fromHeight(_getButtonHeight(context)),
      ),
      padding: WidgetStateProperty.all(_getButtonPadding(context)),
      elevation: WidgetStateProperty.resolveWith((states) {
        final isDesktop = ResponsiveHelper.isDesktop(context) || 
                         ResponsiveHelper.isLargeDesktop(context);
        
        if (states.contains(WidgetState.disabled)) return 0;
        if (states.contains(WidgetState.pressed)) return isDesktop ? 1 : 2;
        if (states.contains(WidgetState.hovered)) return isDesktop ? 2 : 4;
        return isDesktop ? 1 : 3;
      }),
    );
  }
}

enum TouchButtonType {
  elevated,
  filled,
  outlined,
  text,
}

enum TouchButtonSize {
  small,
  medium,
  large,
}

/// Touch-optimized icon button with proper sizing
class TouchOptimizedIconButton extends StatelessWidget {
  const TouchOptimizedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.style,
    this.size = TouchIconButtonSize.medium,
    this.type = TouchIconButtonType.standard,
    this.hapticFeedback = true,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;
  final ButtonStyle? style;
  final TouchIconButtonSize size;
  final TouchIconButtonType type;
  final bool hapticFeedback;

  @override
  Widget build(BuildContext context) {
    final buttonSize = _getButtonSize(context);
    final iconSize = _getIconSize(context);
    
    void onPressedWithHaptic() {
      if (hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      onPressed?.call();
    }
    
    switch (type) {
      case TouchIconButtonType.standard:
        return IconButton(
          onPressed: onPressedWithHaptic,
          icon: icon,
          tooltip: tooltip,
          style: style ?? _getDefaultStyle(context),
          iconSize: iconSize,
        );
        
      case TouchIconButtonType.filled:
        return IconButton.filled(
          onPressed: onPressedWithHaptic,
          icon: icon,
          tooltip: tooltip,
          style: style ?? _getDefaultStyle(context),
          iconSize: iconSize,
        );
        
      case TouchIconButtonType.outlined:
        return IconButton.outlined(
          onPressed: onPressedWithHaptic,
          icon: icon,
          tooltip: tooltip,
          style: style ?? _getDefaultStyle(context),
          iconSize: iconSize,
        );
    }
  }
  
  double _getButtonSize(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    switch (size) {
      case TouchIconButtonSize.small:
        return isDesktop ? 32 : 36;
      case TouchIconButtonSize.medium:
        return isDesktop ? 40 : Breakpoints.minTouchTarget;
      case TouchIconButtonSize.large:
        return isDesktop ? 48 : Breakpoints.recommendedTouchTarget;
    }
  }
  
  double _getIconSize(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    switch (size) {
      case TouchIconButtonSize.small:
        return isDesktop ? 16 : 18;
      case TouchIconButtonSize.medium:
        return isDesktop ? 20 : 24;
      case TouchIconButtonSize.large:
        return isDesktop ? 24 : 28;
    }
  }
  
  ButtonStyle _getDefaultStyle(BuildContext context) {
    final buttonSize = _getButtonSize(context);
    
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
      maximumSize: WidgetStateProperty.all(Size(buttonSize, buttonSize)),
    );
  }
}

enum TouchIconButtonSize {
  small,
  medium,
  large,
}

enum TouchIconButtonType {
  standard,
  filled,
  outlined,
}

/// Touch-optimized card with proper touch targets and feedback
class TouchOptimizedCard extends StatelessWidget {
  const TouchOptimizedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.margin,
    this.elevation,
    this.color,
    this.shape,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final ShapeBorder? shape;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    final cardElevation = elevation ?? (isDesktop ? 1 : 2);
    final cardMargin = margin ?? ResponsiveHelper.getResponsivePadding(
      context,
      mobile: const EdgeInsets.all(8),
      tablet: const EdgeInsets.all(12),
      desktop: const EdgeInsets.all(16),
    );
    
    return Card(
      margin: cardMargin,
      elevation: selected ? cardElevation + 2 : cardElevation,
      color: selected 
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : color,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        side: selected 
            ? BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      clipBehavior: clipBehavior,
      child: InkWell(
        onTap: onTap != null ? () {
          HapticFeedback.lightImpact();
          onTap!();
        } : null,
        onLongPress: onLongPress != null ? () {
          HapticFeedback.mediumImpact();
          onLongPress!();
        } : null,
        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        child: Container(
          constraints: BoxConstraints(
            minHeight: Breakpoints.minTouchTarget,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Touch-optimized list tile with proper sizing
class TouchOptimizedListTile extends StatelessWidget {
  const TouchOptimizedListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dense,
    this.contentPadding,
    this.shape,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool? dense;
  final EdgeInsetsGeometry? contentPadding;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    final effectiveDense = dense ?? false;
    final minHeight = effectiveDense 
        ? (isDesktop ? 40.0 : 48.0)
        : (isDesktop ? 48.0 : Breakpoints.recommendedTouchTarget);
    
    final effectivePadding = contentPadding ?? EdgeInsets.symmetric(
      horizontal: isDesktop ? 24 : 16,
      vertical: isDesktop ? 8 : 4,
    );
    
    return Material(
      color: selected 
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      shape: shape,
      child: InkWell(
        onTap: onTap != null ? () {
          HapticFeedback.lightImpact();
          onTap!();
        } : null,
        onLongPress: onLongPress != null ? () {
          HapticFeedback.mediumImpact();
          onLongPress!();
        } : null,
        customBorder: shape,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: effectivePadding,
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: isDesktop ? 20 : 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (title != null) 
                      DefaultTextStyle(
                        style: theme.textTheme.bodyLarge!,
                        child: title!,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      DefaultTextStyle(
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: isDesktop ? 20 : 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Touch-optimized checkbox with proper sizing
class TouchOptimizedCheckbox extends StatelessWidget {
  const TouchOptimizedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.activeColor,
    this.checkColor,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final Color? activeColor;
  final Color? checkColor;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || 
                     ResponsiveHelper.isLargeDesktop(context);
    
    return SizedBox(
      height: Breakpoints.minTouchTarget,
      width: Breakpoints.minTouchTarget,
      child: Checkbox(
        value: value,
        onChanged: onChanged != null ? (newValue) {
          HapticFeedback.lightImpact();
          onChanged!(newValue);
        } : null,
        tristate: tristate,
        activeColor: activeColor,
        checkColor: checkColor,
        materialTapTargetSize: isDesktop 
            ? MaterialTapTargetSize.shrinkWrap 
            : MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// Touch-optimized switch with proper sizing
class TouchOptimizedSwitch extends StatelessWidget {
  const TouchOptimizedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Breakpoints.minTouchTarget,
      child: Switch(
        value: value,
        onChanged: onChanged != null ? (newValue) {
          HapticFeedback.lightImpact();
          onChanged!(newValue);
        } : null,
        activeColor: activeColor,
        inactiveThumbColor: inactiveThumbColor,
        inactiveTrackColor: inactiveTrackColor,
      ),
    );
  }
}