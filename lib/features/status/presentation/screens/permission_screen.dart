import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:status_saver/core/utils/permission_checker.dart';

class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permission Required")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.grey),
               SizedBox(height: 24.h),
              const Text(
                "We need access to your media files to show and save WhatsApp statuses.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                icon: const Icon(Icons.security),
                label: const Text("Grant Permission"),
                onPressed: () =>
                    ref.read(permissionProvider.notifier).openPhoneSettings(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
