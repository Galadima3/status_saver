import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/features/status/repository/status_repository.dart';
import 'package:status_saver/features/status/services/share_services.dart';
import 'package:video_player/video_player.dart';

enum Options { repost, share, save }

class VideoDetailScreen extends ConsumerStatefulWidget {
  final File video;
  const VideoDetailScreen({super.key, required this.video});

  @override
  ConsumerState<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends ConsumerState<VideoDetailScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final repo = ref.read(statusRepositoryProvider);
    final saved = await repo.isStatusSaved(widget.video);
    setState(() => _isSaved = saved);
  }

  Options? _selectedOption;
  @override
  Widget build(BuildContext context) {
    final chewieAsync = ref.watch(videoPlayerProvider(widget.video));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Status Saver',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: chewieAsync.when(
          data: (chewieController) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                // Ensure Chewie takes up available space
                child: AspectRatio(
                  aspectRatio:
                      chewieController.videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: chewieController),
                ),
              ),
              SizedBox(height: 10.h),
              SegmentedButton<Options>(
                emptySelectionAllowed: true,
                selected: _selectedOption == null ? {} : {_selectedOption!},
                segments: [
                  const ButtonSegment<Options>(
                    value: Options.repost,
                    label: Text('Repost'),
                    icon: Icon(CupertinoIcons.arrow_2_squarepath),
                  ),
                  const ButtonSegment<Options>(
                    value: Options.share,
                    label: Text('Share'),
                    icon: Icon(Icons.share),
                  ),
                  ButtonSegment<Options>(
                    value: Options.save,
                    label: Text(_isSaved ? 'Saved' : 'Save'),
                    icon: Icon(
                      _isSaved
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.cloud_download,
                      color: _isSaved ? Colors.green : null,
                    ),
                  ),
                ],
                onSelectionChanged: (Set<Options> newSelection) async {
                  setState(() {
                    _selectedOption = newSelection.isEmpty
                        ? null
                        : newSelection.first;
                  });

                  if (_selectedOption == null) return;

                  final statusRepo = ref.read(statusRepositoryProvider);

                  switch (_selectedOption!) {
                    case Options.repost:
                      try {
                        await ShareService.repostToWhatsApp(widget.video);

                        // log("Reposted via WhatsApp: ${widget.video.path}");
                      } catch (e) {
                        log("Error reposting: $e");
                      }
                      break;

                    case Options.share:
                      try {
                        final shareParams = ShareParams(
                          text: 'Check out this status!',
                          files: [XFile(widget.video.path)],
                          // sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
                        );
                        await SharePlus.instance.share(shareParams);

                        log("Shared: ${widget.video.path}");
                      } catch (e) {
                        log("Error sharing: $e");
                      }
                      break;

                    case Options.save:
                      final success = await statusRepo.saveStatus(widget.video);
                      if (success) {
                        setState(() => _isSaved = true);
                      }
                      break;
                  }
                },
              ),

              SizedBox(height: 10.h),
            ],
          ),
          loading: () => const Stack(
            alignment: Alignment.center,
            children: [CircularProgressIndicator()],
          ),
          error: (err, _) => Text('Error: $err'),
        ),
      ),
    );
  }
}

final videoPlayerProvider = FutureProvider.autoDispose
    .family<ChewieController, File>((ref, file) async {
      final videoController = VideoPlayerController.file(file);
      await videoController.initialize();

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: videoController.value.aspectRatio,
      );

      ref.onDispose(() {
        videoController.dispose();
        chewieController.dispose();
      });

      return chewieController;
    });
