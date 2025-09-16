import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:status_saver/core/routing/route_paths.dart';
import 'package:status_saver/core/routing/scaffold_with_navbar.dart';
import 'package:status_saver/core/utils/permission_checker.dart';
import 'package:status_saver/features/history/presentation/history_screen.dart';
import 'package:status_saver/features/status/presentation/screens/images/image_detail_screen.dart';
import 'package:status_saver/features/status/presentation/screens/media_detail_screen.dart';
import 'package:status_saver/features/status/presentation/screens/permission_screen.dart';
import 'package:status_saver/features/status/presentation/screens/splash_screen.dart';
import 'package:status_saver/features/status/presentation/screens/status_screen.dart';
import 'package:status_saver/features/settings/presentation/settings_screen.dart';
import 'package:status_saver/features/status/presentation/screens/videos/video_detail_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final permissionAsync = ref.watch(permissionProvider);
      return permissionAsync.when(
        loading: () => null, // stay on splash
        error: (_, __) => RoutePaths.permission,
        data: (granted) {
          if (state.matchedLocation == RoutePaths.splash) {
            return granted ? RoutePaths.status : RoutePaths.permission;
          }
          if (state.matchedLocation == RoutePaths.status && !granted) {
            return RoutePaths.permission;
          }
          return null;
        },
      );
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.permission,
        builder: (_, __) => const PermissionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.status,
                builder: (_, __) => const StatusScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.history,
                builder: (_, __) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.imageDetail,
        builder: (context, state) {
          final selectedImage = state.extra as File;
          return ImageDetailScreen(image: selectedImage);
        },
      ),
      GoRoute(
        path: RoutePaths.videoDetail,
        builder: (context, state) {
          final selectedVideo = state.extra as File;
          return VideoDetailScreen(video: selectedVideo);
        },
      ),
      // ✅ Unified detail route
      GoRoute(
        path: RoutePaths.mediaDetail,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final files = extras["files"] as List<File>;
          final index = extras["index"] as int;

          return MediaDetailScreen(files: files, initialIndex: index);
        },
      ),
    ],
  );
});
