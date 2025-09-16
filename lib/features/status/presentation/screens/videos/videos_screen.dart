import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:status_saver/core/routing/route_paths.dart';
import 'package:status_saver/features/status/presentation/widgets/shimmer_thumbnail.dart';
import 'package:status_saver/features/status/repository/status_repository.dart';
import 'package:status_saver/features/status/services/toast_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// Combined provider that fetches both thumbnail (in-memory) and saved status
final videoCardProvider =
    FutureProvider.family<({Uint8List? thumbData, bool isSaved}), File>((
      ref,
      file,
    ) async {
  final link = ref.keepAlive();
  ref.onDispose(() {
    log('Disposed videoCardProvider for ${file.path}');
  });
  final timer = Timer(const Duration(minutes: 1), () {
    link.close();
  });
  ref.onDispose(timer.cancel);

  // get thumbnail in memory (no side effect on disk)
  final thumbData = await VideoThumbnail.thumbnailData(
    video: file.path,
    imageFormat: ImageFormat.PNG,
    quality: 50,
  );

  // get saved status
  final isSaved = await ref.watch(savedStatusProvider(file).future);

  return (thumbData: thumbData, isSaved: isSaved);
});

class VideosScreen extends ConsumerWidget {
  final List<File> videos;
  const VideosScreen({super.key, required this.videos});

  static const _mediaChannel = MethodChannel('status_saver/media');

  Future<void> _handleSaveVideos(
    BuildContext context,
    WidgetRef ref,
    File file,
  ) async {
    try {
      final repo = ref.read(statusRepositoryProvider);
      final success = await repo.saveStatus(file);

      switch (success) {
        case true:
          await _handleSuccessfulVideoSave(repo, file, ref);
          if (!context.mounted) return;
          ToastService.showSuccess(context, message: 'Saved successfully!');
          break;
        case false:
          if (!context.mounted) return;
          ToastService.showError(context, message: 'Failed to save');
      }
    } catch (e) {
      if (!context.mounted) return;
      ToastService.showError(context, message: 'Error: ${e.toString()}');
    }
  }

  Future<void> _handleSuccessfulVideoSave(
    StatusRepository repo,
    File file,
    WidgetRef ref,
  ) async {
    final destPath = p.join(repo.savedStatusDir, p.basename(file.path));
    try {
      await _mediaChannel.invokeMethod('scanMedia', destPath);
    } catch (_) {
      // ignore scan failures
    }
    ref.invalidate(videoCardProvider(file));
    ref.invalidate(savedStatusProvider(file));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (videos.isEmpty) {
      return const Center(child: Text('No video statuses found.'));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
        childAspectRatio: 0.65,
      ),
      padding: const EdgeInsets.all(8.0),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final file = videos[index];
        final cardAsync = ref.watch(videoCardProvider(file));
        return cardAsync.when(
          data: (data) {
            final thumbData = data.thumbData;
            final isSaved = data.isSaved;

            final thumbnail = thumbData != null
                ? Image.memory(thumbData, fit: BoxFit.cover)
                : const Center(
                    child: Icon(
                      Icons.videocam,
                      size: 50.0,
                      color: Colors.white,
                    ),
                  );

            return Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.push(RoutePaths.videoDetail, extra: file),
                    child: thumbnail,
                  ),
                  // Centered play icon
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  // Bottom-right download/check icon
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: isSaved
                          ? null
                          : () => _handleSaveVideos(context, ref, file),
                      child: Container(
                        height: 30.h,
                        width: 30.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSaved
                              ? Colors.green
                              : const Color(0xff25D366),
                        ),
                        child: Icon(
                          isSaved
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.cloud_download,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const ShimmerThumbnail(borderRadius: 10.0),
          ),
          error: (_, __) => const Card(child: Center(child: Icon(Icons.error))),
        );
      },
    );
  }
}
