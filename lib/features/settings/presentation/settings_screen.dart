import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:status_saver/features/settings/presentation/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Settings"), centerTitle: true),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: settings.darkMode,
                onChanged: (value) => ref
                    .read(settingsControllerProvider.notifier)
                    .updateSettings(settings.copyWith(darkMode: value)),
              ),
              SizedBox(
                height: 15.h,
              ),
              ListTile(
                title: const Text("Save Path"),
                subtitle: Text(settings.savePath),
                trailing: IconButton(
                  icon: const Icon(Icons.folder),
                  onPressed: () async {
                    String? selectedDir = await FilePicker.platform
                        .getDirectoryPath();
                    if (selectedDir != null) {
                      ref
                          .read(settingsControllerProvider.notifier)
                          .updateSettings(
                            settings.copyWith(savePath: selectedDir),
                          );
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListView.builder(
              itemCount: 4, // Number of placeholder items
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      // A shimmer placeholder that looks like a title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 16,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // A shimmer placeholder that looks like a trailing icon or switch
                      SizedBox(
                        width: 40,
                        height: 20,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
