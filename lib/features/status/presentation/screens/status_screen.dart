import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:status_saver/core/theming/app_theme.dart';
import 'package:status_saver/features/status/presentation/screens/images/images_screen.dart';
import 'package:status_saver/features/status/presentation/screens/videos/videos_screen.dart';
import 'package:status_saver/features/status/repository/status_repository.dart';

/// Combined Provider to handle both Image & video AsyncValue
final statusProvider = FutureProvider<({List<File> images, List<File> videos})>(
  (ref) async {
    final imagesFuture = ref.watch(imageStatusProvider.future);
    final videosFuture = ref.watch(videoStatusProvider.future);
    final results = await Future.wait([imagesFuture, videosFuture]);
    return (images: results[0], videos: results[1]);
  },
);

class StatusScreen extends ConsumerStatefulWidget {
  const StatusScreen({super.key});

  @override
  ConsumerState<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends ConsumerState<StatusScreen> {
  String _selectedSegment = 'Photos';

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(statusProvider);
    final segmentedTheme = Theme.of(context).extension<SegmentedControlTheme>();

    return Scaffold(
      appBar: AppBar(
        title: CupertinoSlidingSegmentedControl<String>(
          backgroundColor: segmentedTheme!.backgroundColor,
          //thumbColor: segmentedTheme!.selectedColor,
          children: {
            'Photos': Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.photo, size: 18),
                  SizedBox(width: 8),
                  Text('Photos'),
                ],
              ),
            ),
            'Videos': Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, size: 18),
                  SizedBox(width: 8),
                  Text('Videos'),
                ],
              ),
            ),
          },
          groupValue: _selectedSegment,
          onValueChanged: (value) => setState(() => _selectedSegment = value!),
          // backgroundColor: Colors.grey.shade100,
          // thumbColor: Colors.white,
        ),
        centerTitle: true,
      ),
      body: statusAsync.when(
        data: (data) {
          if (_selectedSegment == 'Photos') {
            return ImagesScreen(images: data.images);
          } else {
            return VideosScreen(videos: data.videos);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
