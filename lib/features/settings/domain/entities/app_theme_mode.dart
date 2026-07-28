enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromName(String? name) {
    for (final mode in AppThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return AppThemeMode.system;
  }
}
