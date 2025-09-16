
class AppSettings {
  final String savePath;
  final bool darkMode;
  final bool showNotifications;

  const AppSettings({
    this.savePath = '/storage/emulated/0/Download/MStatusSaver',
    this.darkMode = false,
    this.showNotifications = true,
  });

  AppSettings copyWith({
    String? savePath,
    bool? darkMode,
    bool? showNotifications,
  }) {
    return AppSettings(
      savePath: savePath ?? this.savePath,
      darkMode: darkMode ?? this.darkMode,
      showNotifications: showNotifications ?? this.showNotifications,
    );
  }

  Map<String, dynamic> toJson() => {
        "savePath": savePath,
        "darkMode": darkMode,
        "showNotifications": showNotifications,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        savePath: json["savePath"],
        darkMode: json["darkMode"],
        showNotifications: json["showNotifications"],
      );
}

