import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:status_saver/core/routing/app_router.dart';
import 'package:status_saver/core/theming/app_theme.dart';
import 'package:status_saver/features/settings/models/settings_model.dart';
import 'package:status_saver/features/settings/presentation/settings_controller.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    // Provider for Settings controller
    final settingsAsync = ref.watch(settingsControllerProvider);
    final AppSettings settings = settingsAsync.value ?? const AppSettings();

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Flutter Demo',
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          darkTheme: AppTheme.dark.copyWith(
            textTheme: AppTheme.dark.textTheme.apply(fontFamily: 'Montserrat'),
          ),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light.copyWith(
            textTheme: AppTheme.light.textTheme.apply(fontFamily: 'Montserrat'),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
