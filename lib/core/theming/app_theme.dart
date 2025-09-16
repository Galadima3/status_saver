import 'package:flutter/material.dart';
import 'package:status_saver/core/theming/app_dark_theme.dart';
import 'package:status_saver/core/theming/app_light_theme.dart';

class AppTheme {
  static ThemeData light = AppLightTheme.build();
  static ThemeData dark = AppDarkTheme.build();
}

class SegmentedControlTheme extends ThemeExtension<SegmentedControlTheme> {
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color borderColor;

  SegmentedControlTheme({
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.borderColor,
  });

  @override
  SegmentedControlTheme copyWith({
    Color? backgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    Color? borderColor,
  }) {
    return SegmentedControlTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  SegmentedControlTheme lerp(
      ThemeExtension<SegmentedControlTheme>? other, double t) {
    if (other is! SegmentedControlTheme) return this;
    return SegmentedControlTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
      unselectedColor: Color.lerp(unselectedColor, other.unselectedColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }
}
