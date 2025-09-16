import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:status_saver/core/theming/app_theme.dart';

class AppDarkTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff25D366),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        toolbarHeight: 50.h,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 8.0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
        selectedIconTheme: IconThemeData(color: scheme.primary, size: 26),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant.withValues(alpha: 0.7), size: 24),
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
