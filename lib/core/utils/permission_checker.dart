import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return _checkAndRequestStoragePermission();
  }

  Future<bool> _checkAndRequestStoragePermission() async {
    bool granted = false;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      debugPrint("SDK INT: $sdkInt");

      if (sdkInt >= 30) {
        // Android 11+ - Need MANAGE_EXTERNAL_STORAGE for WhatsApp status access
        final manageStorage = await Permission.manageExternalStorage.request();
        debugPrint("MANAGE_EXTERNAL_STORAGE permission: $manageStorage");
        granted = manageStorage.isGranted;

        if (!granted) {
          // Fallback to scoped storage permissions
          final photos = await Permission.photos.request();
          final videos = await Permission.videos.request();
          debugPrint("Photos permission: $photos");
          debugPrint("Videos permission: $videos");
          granted = photos.isGranted && videos.isGranted;
        }
      } else {
        // Android 10 and below - Use legacy storage permission
        final storage = await Permission.storage.request();
        debugPrint("Storage permission: $storage");
        granted = storage.isGranted;
      }
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.request();
      granted = photos.isGranted;
    } else {
      granted = true;
    }

    return granted;
  }

  Future<void> requestPermissions() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _checkAndRequestStoragePermission());
  }

  Future<void> openPhoneSettings() async {
    await openAppSettings();
  }
}

// Provider
final permissionProvider = AsyncNotifierProvider<PermissionNotifier, bool>(
  () => PermissionNotifier(),
);
