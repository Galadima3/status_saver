import 'package:flutter/material.dart';
import 'package:status_saver/core/theming/app_theme.dart';

class AppLightTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff25D366),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Montserrat',

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actionsIconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500, 
          fontFamily: 'Montserrat',
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 8.0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          //fontWeight: FontWeight.w500,
          color: scheme.primary,
          fontFamily: 'Montserrat',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          //fontWeight: FontWeight.w400,
          color: scheme.onSurfaceVariant..withValues(alpha: 0.7),
          fontFamily: 'Montserrat',
        ),
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 26),
        unselectedIconTheme: IconThemeData(
          color: scheme.onSurfaceVariant..withValues(alpha: 0.7),
          size: 24,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      extensions: [
        SegmentedControlTheme(
          backgroundColor: scheme.surfaceContainerHighest,
          selectedColor: scheme.primary,
          unselectedColor: scheme.onSurfaceVariant.withValues(alpha: 0.6),
          borderColor: scheme.outline,
        ),
      ],
    );
  }
}