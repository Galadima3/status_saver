import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/features/settings/models/settings_model.dart';

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return _loadSettings();
  }

  Future<AppSettings> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("app_settings");
    if (data != null) {
      return AppSettings.fromJson(jsonDecode(data));
    }
    // Returns default value if no settings are found.
    return const AppSettings();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    state = AsyncValue.data(newSettings);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_settings", jsonEncode(newSettings.toJson()));
  }

  // A method to refresh the state from storage.
  Future<void> refreshSettings() async {
    // Set the state to loading to show a spinner.
    state = const AsyncValue.loading();
    // Guard against errors when reloading the data.
    state = await AsyncValue.guard(() => _loadSettings());
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );
