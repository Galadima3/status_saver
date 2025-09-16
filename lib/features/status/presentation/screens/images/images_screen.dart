import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:status_saver/core/routing/route_paths.dart';
import 'package:status_saver/features/status/presentation/screens/status_screen.dart';
import 'package:status_saver/features/status/repository/status_repository.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:status_saver/features/status/services/toast_service.dart';

class ImagesScreen extends ConsumerWidget {
  final List<File> images;
  const ImagesScreen({super.key, required this.images});

  static const _mediaChannel = MethodChannel('status_saver/media');

  Future<void> _handleSaveImages(
    BuildContext context,
    WidgetRef ref,
    File file,
  ) async {
    //DialogHelper.showLoadingDialog(context);
    try {
      final repo = ref.read(statusRepositoryProvider);
      final success = await repo.saveStatus(file);
      switch (success) {
        case true:
          await _handleSuccessfulImageSave(repo, file, ref);
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
    } finally {
      // ignore: use_build_context_synchronously
      //DialogHelper.dismissLoadingDialog(context);
    }
  }

  Future<void> _handleSuccessfulImageSave(
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

    ref.invalidate(savedStatusProvider(file));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (images.isEmpty) {
      return const Center(child: Text('No image statuses found.'));
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(statusProvider),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 7.0,
          crossAxisSpacing: 7.0,
          childAspectRatio: 0.65,
        ),
        padding: EdgeInsets.all(8.0.r),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final file = images[index];
          final savedAsync = ref.watch(savedStatusProvider(file));
      
          return Stack(
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0.r),
                ),
                child: SizedBox.expand(
                  child: GestureDetector(
                    onTap: () =>
                        context.push(RoutePaths.imageDetail, extra: file),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        log(error.toString());
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(7.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: savedAsync.when(
                    data: (isSaved) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(30.r),
                        onTap: isSaved
                            ? null
                            : () => _handleSaveImages(context, ref, file),
      
                        child: Container(
                          height: 30.h,
                          width: 30.w,
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
                      );
                    },
                    loading: () =>  SizedBox(
                      height: 30.h,
                      width: 30.w,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, __) => const Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
