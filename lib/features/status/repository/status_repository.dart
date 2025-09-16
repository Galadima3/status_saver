import 'dart:developer';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:status_saver/features/settings/models/settings_model.dart';
import 'package:status_saver/features/settings/presentation/settings_controller.dart';

class StatusRepository {
  final Ref _ref;
  StatusRepository(this._ref);
  // Updated WhatsApp status directory paths for Android 11+
  final List<String> _whatsappStatusPaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
  ];

  String get savedStatusDir {
    // Read the SettingsControllerProvider
    final settings = _ref.read(settingsControllerProvider);
    // Pick out the nullable settings value
    AppSettings? settingsAsync = settings.value;
    // Return the savePath if it exists, else return a default path.
    return settingsAsync?.savePath ?? '/storage/emulated/0/Download/MStatusSaver';
  }

  Directory? _getWorkingStatusDirectory() {
    for (String path in _whatsappStatusPaths) {
      final dir = Directory(path);
      if (dir.existsSync()) {
        log("Found WhatsApp status directory: $path");
        return dir;
      }
    }
    log("No WhatsApp status directory found");
    return null;
  }

  /// Get all image status files
  Future<List<File>> getImageStatuses() async {
    try {
      final statusDir = _getWorkingStatusDirectory();
      if (statusDir == null) return [];

      final List<File> files = statusDir
          .listSync()
          .where(
            (item) =>
                item is File &&
                (item.path.endsWith('.jpg') ||
                    item.path.endsWith('.jpeg') ||
                    item.path.endsWith('.png') ||
                    item.path.endsWith('.webp')),
          )
          .map((item) => File(item.path))
          .toList();

      log("Number of Image Status: ${files.length}");
      return files;
    } catch (e) {
      log('Error getting image statuses: $e');
      return [];
    }
  }

  /// Get all video status files
  Future<List<File>> getVideoStatuses() async {
    try {
      final statusDir = _getWorkingStatusDirectory();
      if (statusDir == null) return [];

      final List<File> files = statusDir
          .listSync()
          .where((item) => item is File && item.path.endsWith('.mp4'))
          .map((item) => File(item.path))
          .toList();

      log("Number of Video Status: ${files.length}");
      return files;
    } catch (e) {
      log('Error getting video statuses: $e');
      return [];
    }
  }

  /// Save an image or video status to a permanent directory
  Future<bool> saveStatus(File sourceFile) async {
    try {
      final destinationDir = Directory(savedStatusDir);
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      final fileName = p.basename(sourceFile.path);
      final destinationPath = p.join(destinationDir.path, fileName);

      await sourceFile.copy(destinationPath);
      log("Status saved to: $destinationPath");
      return true;
    } catch (e) {
      log('Error saving status: $e');
      return false;
    }
  }

  /// Delete a status file from the device
  Future<bool> deleteStatus(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      log('Error deleting status: $e');
      return false;
    }
  }

  /// Check if Status is saved to Local Storage
  Future<bool> isStatusSaved(File sourceFile) async {
    final fileName = p.basename(sourceFile.path);
    final destinationPath = p.join(savedStatusDir, fileName);
    return File(destinationPath).exists();
  }

  /// Get all saved statii
  Future<List<File>> getSavedStatii() async {
    try {
      final savedDir = Directory(savedStatusDir);

      if (!savedDir.existsSync()) {
        log("Saved statuses directory does not exist");
        return [];
      }
      final List<File> files = savedDir
          .listSync()
          .where(
            (item) =>
                item is File &&
                (item.path.endsWith('.mp4') ||
                    item.path.endsWith('.jpg') ||
                    item.path.endsWith('.jpeg') ||
                    item.path.endsWith('.png') ||
                    item.path.endsWith('.webp')),
          )
          .map((item) => File(item.path))
          .toList();

      log("Number of Saved Status: ${files.length}");
      return files;
    } catch (e) {
      log('Error getting video statuses: $e');
      return [];
    }
  }
}

// Provider
final statusRepositoryProvider = Provider<StatusRepository>((ref) {
  return StatusRepository(ref);
});

// Image Provider
final imageStatusProvider = FutureProvider<List<File>>((ref) async {
  final repository = ref.watch(statusRepositoryProvider);
  return repository.getImageStatuses();
});

// Video Provider
final videoStatusProvider = FutureProvider<List<File>>((ref) async {
  final repository = ref.watch(statusRepositoryProvider);
  return repository.getVideoStatuses();
});

// Saved Status Provider
final savedStatiiProvider = FutureProvider<List<File>>((ref) async {
  final repo = ref.watch(statusRepositoryProvider);
  return repo.getSavedStatii();
});

// Family provider to check if a file is already saved
final savedStatusProvider = FutureProvider.family<bool, File>((
  ref,
  file,
) async {
  final repo = ref.read(statusRepositoryProvider);
  return repo.isStatusSaved(file);
});
