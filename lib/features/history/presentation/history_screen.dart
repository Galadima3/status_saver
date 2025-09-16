// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:status_saver/core/routing/route_paths.dart';
import 'package:status_saver/features/status/repository/status_repository.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:shimmer/shimmer.dart';

/// Unified provider: returns list of (file, thumbData, isVideo)
final historyCardsProvider =
    FutureProvider<List<({File file, Uint8List? thumbData, bool isVideo})>>(
        (ref) async {
  final repo = ref.watch(statusRepositoryProvider);
  final files = await repo.getSavedStatii();

  return Future.wait(
    files.map((file) async {
      final isVideo = file.path.toLowerCase().endsWith('.mp4');
      Uint8List? thumbData;
      if (isVideo) {
        thumbData = await VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: ImageFormat.PNG,
          quality: 50,
        );
      }
      return (file: file, thumbData: thumbData, isVideo: isVideo);
    }),
  );
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved status',
          // style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(historyCardsProvider);
          await ref.read(historyCardsProvider.future); 
        },
        child: historyAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  const Center(
                      child: Text("No saved statuses found")),
                ],
              );
            }
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 7.0,
                crossAxisSpacing: 7.0,
                childAspectRatio: 0.65,
              ),
              padding: EdgeInsets.all(8.0.r),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () => context.push(
                          RoutePaths.mediaDetail,
                          extra: {
                            "files": items.map((e) => e.file).toList(),
                            "index": index,
                          },
                        ),
                        child: item.isVideo
                            ? Image.memory(item.thumbData!, fit: BoxFit.cover)
                            : Image.file(item.file, fit: BoxFit.cover),
                      ),
                      if (item.isVideo)
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 7.0,
              crossAxisSpacing: 7.0,
              childAspectRatio: 0.65,
            ),
            padding: EdgeInsets.all(8.0.r),
            itemBuilder: (context, index) => Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(color: Colors.white),
              ),
            ),
          ),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}