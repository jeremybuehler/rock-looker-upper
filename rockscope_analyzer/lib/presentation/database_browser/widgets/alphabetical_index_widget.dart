import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget for alphabetical index navigation on the right edge
/// Enables quick navigation through large datasets
class AlphabeticalIndexWidget extends StatelessWidget {
  final String selectedLetter;
  final ValueChanged<String> onLetterTap;

  const AlphabeticalIndexWidget({
    super.key,
    required this.selectedLetter,
    required this.onLetterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final letters =
        List.generate(26, (index) => String.fromCharCode(65 + index));

    return Container(
      width: 8.w,
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: letters.map((letter) {
          final isSelected = letter == selectedLetter;

          return GestureDetector(
            onTap: () => onLetterTap(letter),
            child: Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
