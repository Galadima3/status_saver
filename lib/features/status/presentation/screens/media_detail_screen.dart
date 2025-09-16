// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:chewie/chewie.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:status_saver/features/history/history_screen.dart';
// import 'package:status_saver/features/status/repository/status_repository.dart';
// import 'package:status_saver/features/status/services/share_services.dart';
// import 'package:status_saver/features/status/services/toast_service.dart';
// import 'package:video_player/video_player.dart';

// enum Options { repost, share, delete }

// class MediaDetailScreen extends ConsumerStatefulWidget {
//   final List<File> files;
//   final int initialIndex;

//   const MediaDetailScreen({
//     super.key,
//     required this.files,
//     required this.initialIndex,
//   });

//   @override
//   ConsumerState<MediaDetailScreen> createState() => _MediaDetailScreenState();
// }

// class _MediaDetailScreenState extends ConsumerState<MediaDetailScreen> {
//   late PageController _pageController;
//   late int _currentIndex;
//   // bool _isSaved = false;
//   Options? _selectedOption;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: _currentIndex);
//     //_checkIfSaved(widget.files[_currentIndex]);
//   }
//   // Future<void> _checkIfSaved(File file) async {
//   //   final repo = ref.read(statusRepositoryProvider);
//   //   final saved = await repo.isStatusSaved(file);
//   //   setState(() => _isSaved = saved);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Status Saver',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: widget.files.length,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentIndex = index;
//                   _selectedOption = null;
//                 });
//                 //_checkIfSaved(widget.files[index]);
//               },
//               itemBuilder: (context, index) {
//                 final file = widget.files[index];

//                 if (file.path.endsWith(".mp4")) {
//                   // Video
//                   return Consumer(
//                     builder: (context, ref, _) {
//                       final chewieAsync = ref.watch(videoPlayerProvider(file));
//                       return chewieAsync.when(
//                         data: (chewieController) => Center(
//                           child: AspectRatio(
//                             aspectRatio: chewieController
//                                 .videoPlayerController
//                                 .value
//                                 .aspectRatio,
//                             child: Chewie(controller: chewieController),
//                           ),
//                         ),
//                         loading: () =>
//                             const Center(child: CircularProgressIndicator()),
//                         error: (err, _) => Center(child: Text("Error: $err")),
//                       );
//                     },
//                   );
//                 } else {
//                   // Image
//                   return Center(
//                     child: InteractiveViewer(
//                       child: Image.file(
//                         file,
//                         fit: BoxFit.contain,
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),

//           SizedBox(height: 10.h),

//           // Common segmented button for all media
//           SegmentedButton<Options>(
//             emptySelectionAllowed: true,
//             selected: _selectedOption == null ? {} : {_selectedOption!},
//             segments: [
//               const ButtonSegment<Options>(
//                 value: Options.repost,
//                 label: Text('Repost'),
//                 icon: Icon(CupertinoIcons.arrow_2_squarepath),
//               ),
//               const ButtonSegment<Options>(
//                 value: Options.share,
//                 label: Text('Share'),
//                 icon: Icon(Icons.share),
//               ),
//               ButtonSegment<Options>(
//                 value: Options.delete,
//                 label: Text("Delete"),
//                 icon: Icon(CupertinoIcons.trash, color: Colors.red),
//               ),
//             ],
//             onSelectionChanged: (Set<Options> newSelection) async {
//               setState(() {
//                 _selectedOption = newSelection.isEmpty
//                     ? null
//                     : newSelection.first;
//               });

//               if (_selectedOption == null) return;

//               final file = widget.files[_currentIndex];
//               final statusRepo = ref.read(statusRepositoryProvider);

//               switch (_selectedOption!) {
//                 case Options.repost:
//                   await ShareService.repostToWhatsApp(file);
//                   break;
//                 case Options.share:
//                   final shareParams = ShareParams(
//                     text: 'Check out this status!',
//                     files: [XFile(file.path)],
//                   );
//                   await SharePlus.instance.share(shareParams);
//                   break;
//                 case Options.delete:
//                   // Show confirmation dialog
//                   final shouldDelete = await showDialog<bool>(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Delete Status'),
//                       content: const Text(
//                         'Are you sure you want to delete this status?',
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.of(context).pop(false),
//                           child: const Text('Cancel'),
//                         ),
//                         TextButton(
//                           onPressed: () => Navigator.of(context).pop(true),
//                           child: const Text('Delete'),
//                         ),
//                       ],
//                     ),
//                   );

//                   if (shouldDelete == true) {
//                     final success = await statusRepo.deleteStatus(file);
//                     if (!mounted) return;

//                     if (success) {
//                       // Remove from local files list
//                       final updatedFiles = List<File>.from(widget.files);
//                       updatedFiles.removeAt(_currentIndex);

//                       if (updatedFiles.isEmpty) {
//                         // No more files, go back
//                         if (context.mounted) context.pop();
//                         return;
//                       }

//                       // Update the files list (you might need to pass this back to parent)
//                       // For now, we'll modify widget.files but consider using a callback
//                       widget.files.clear();
//                       widget.files.addAll(updatedFiles);

//                       setState(() {
//                         // Adjust current index if needed
//                         if (_currentIndex >= widget.files.length) {
//                           _currentIndex = widget.files.length - 1;
//                         }
//                       });

//                       // Navigate to correct page
//                       _pageController.animateToPage(
//                         _currentIndex,
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                       if (!context.mounted) return;
//                       ToastService.showSuccess(
//                         context,
//                         message: 'Status deleted successfully',
//                       );

//                       ref.invalidate(historyCardsProvider);
//                     } else {
//                       // Show error message
//                       if (!context.mounted) return;
//                       ToastService.showError(
//                         context,
//                         message: 'Failed to delete status',
//                       );
//                     }
//                   }
//                   break;
//               }
//             },
//           ),

//           SizedBox(height: 10.h),
//         ],
//       ),
//     );
//   }
// }

// /// Video player provider
// final videoPlayerProvider = FutureProvider.autoDispose
//     .family<ChewieController, File>((ref, file) async {
//       final videoController = VideoPlayerController.file(file);
//       await videoController.initialize();

//       final chewieController = ChewieController(
//         videoPlayerController: videoController,
//         autoPlay: true,
//         looping: false,
//         aspectRatio: videoController.value.aspectRatio,
//       );

//       ref.onDispose(() {
//         videoController.dispose();
//         chewieController.dispose();
//       });

//       return chewieController;
//     });

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/features/history/presentation/history_screen.dart';
import 'package:status_saver/features/status/repository/status_repository.dart';
import 'package:status_saver/features/status/services/share_services.dart';
import 'package:status_saver/features/status/services/toast_service.dart';
import 'package:video_player/video_player.dart';

enum Options { repost, share, delete }

class MediaDetailScreen extends ConsumerStatefulWidget {
  final List<File> files;
  final int initialIndex;

  const MediaDetailScreen({
    super.key,
    required this.files,
    required this.initialIndex,
  });

  @override
  ConsumerState<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends ConsumerState<MediaDetailScreen> {
  late PageController _pageController;
  late List<File> _files;
  late int _currentIndex;
  Options? _selectedOption;

  @override
  void initState() {
    super.initState();
    _files = List<File>.from(widget.files); // local copy
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<bool> _confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Status'),
            content: const Text('Are you sure you want to delete this status?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleOption(Options option) async {
    final file = _files[_currentIndex];
    final statusRepo = ref.read(statusRepositoryProvider);

    switch (option) {
      case Options.repost:
        await ShareService.repostToWhatsApp(file);
        break;

      case Options.share:
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Check out this status!',
          ),
        );

        break;

      case Options.delete:
        final shouldDelete = await _confirmDelete();
        if (!shouldDelete) return;

        final success = await statusRepo.deleteStatus(file);
        if (!mounted) return;

        if (success) {
          setState(() {
            _files.removeAt(_currentIndex);
            if (_files.isEmpty) {
              context.pop();
              return;
            }
            _currentIndex = _currentIndex.clamp(0, _files.length - 1);
          });

          _pageController.jumpToPage(_currentIndex);
          ToastService.showSuccess(context, message: 'Status deleted');
          ref.invalidate(historyCardsProvider);
        } else {
          ToastService.showError(context, message: 'Failed to delete status');
        }
        break;
    }
  }

  Widget _buildVideo(File file) {
    return Consumer(
      builder: (context, ref, _) {
        final chewieAsync = ref.watch(videoPlayerProvider(file));
        return chewieAsync.when(
          data: (chewieController) => Center(
            child: AspectRatio(
              aspectRatio:
                  chewieController.videoPlayerController.value.aspectRatio,
              child: Chewie(controller: chewieController),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
        );
      },
    );
  }

  Widget _buildImage(File file) {
    return Center(
      child: InteractiveViewer(
        child: Image.file(
          file,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_files.isEmpty) {
      return const Scaffold(body: Center(child: Text("No media available")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Status Saver',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _files.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _selectedOption = null;
                });
              },
              itemBuilder: (context, index) {
                final file = _files[index];
                return file.path.endsWith(".mp4")
                    ? _buildVideo(file)
                    : _buildImage(file);
              },
            ),
          ),
          SizedBox(height: 10.h),

          // Segmented button
          SegmentedButton<Options>(
            emptySelectionAllowed: true,
            selected: _selectedOption == null ? {} : {_selectedOption!},
            segments: const [
              ButtonSegment(
                value: Options.repost,
                label: Text('Repost'),
                icon: Icon(CupertinoIcons.arrow_2_squarepath),
              ),
              ButtonSegment(
                value: Options.share,
                label: Text('Share'),
                icon: Icon(Icons.share),
              ),
              ButtonSegment(
                value: Options.delete,
                label: Text("Delete"),
                icon: Icon(CupertinoIcons.trash, color: Colors.red),
              ),
            ],
            onSelectionChanged: (selection) async {
              final option = selection.isEmpty ? null : selection.first;
              setState(() => _selectedOption = option);
              if (option != null) await _handleOption(option);
            },
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

/// Video player provider
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
