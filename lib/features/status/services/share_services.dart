import 'dart:developer';
import 'dart:io';
import 'package:device_apps_plus/device_apps_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static const _channel = MethodChannel("status_saver/share");

  static Future<void> repostToWhatsApp(File video) async {
    // Optional fast check before even hitting MethodChannel
    final isInstalled = await DeviceAppsPlus().isAppInstalled("com.whatsapp");

    if (!isInstalled) {
      log("WhatsApp not installed → falling back to system share");
      await _fallbackShare(video);
      return;
    }

    try {
      final mimeType = lookupMimeType(video.path) ?? "video/mp4";
      final uri = Uri.file(video.path);

      final intent = {
        "type": mimeType,
        "package": "com.whatsapp",
        "stream": uri.toString(),
        "extra_text": "Check this out!",
      };

      await _channel.invokeMethod("shareToWhatsApp", intent);
      debugPrint("Shared to WhatsApp successfully");

    } on PlatformException catch (e) {
      if (e.code == "WHATSAPP_NOT_INSTALLED") {
        debugPrint("WhatsApp missing → using system share");
        await _fallbackShare(video);
      } else {
        debugPrint("Error from native: ${e.message}");
        await _fallbackShare(video);
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
      await _fallbackShare(video);
    }
  }

  static Future<void> _fallbackShare(File video) async {
    final params = ShareParams(
      files: [XFile(video.path, mimeType: lookupMimeType(video.path))],
      text: "Check this out!",
    );
    await SharePlus.instance.share(params);
  }
}
