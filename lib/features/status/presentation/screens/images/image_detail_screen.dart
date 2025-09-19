import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/features/status/repository/status_repository.dart';
import 'package:status_saver/features/status/services/share_services.dart';

enum Options { repost, share, save }

class ImageDetailScreen extends ConsumerStatefulWidget {
  final File image;
  const ImageDetailScreen({super.key, required this.image});

  @override
  ConsumerState<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends ConsumerState<ImageDetailScreen> {
  bool _isSaved = false;
  Options? _selectedOption;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final repo = ref.read(statusRepositoryProvider);
    final saved = await repo.isStatusSaved(widget.image);
    setState(() => _isSaved = saved);
  }

  @override
  Widget build(BuildContext context) {
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
            child: Center(
              child: InteractiveViewer(
                // Allow pinch-zoom and pan
                child: Image.file(
                  widget.image,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
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
                _selectedOption =
                    newSelection.isEmpty ? null : newSelection.first;
              });
              if (_selectedOption == null) return;
              final statusRepo = ref.read(statusRepositoryProvider);
              switch (_selectedOption!) {
                case Options.repost:
                  try {
                    await ShareService.repostToWhatsApp(widget.image);
                    log("Reposted image via WhatsApp: ${widget.image.path}");
                  } catch (e) {
                    log("Error reposting: $e");
                  }
                  break;

                case Options.share:
                  try {
                    final shareParams = ShareParams(
                      text: 'Check out this status!',
                      files: [XFile(widget.image.path)],
                    );
                    await SharePlus.instance.share(shareParams);
                    log("Shared image: ${widget.image.path}");
                  } catch (e) {
                    log("Error sharing: $e");
                  }
                  break;

                case Options.save:
                  final success = await statusRepo.saveStatus(widget.image);
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
    );
  }
}
