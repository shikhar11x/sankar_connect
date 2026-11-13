import 'package:flutter/material.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/local_storage.dart';

/// Holds the selected [ThemeMode] and persists it in SharedPreferences,
/// so the user's choice survives an app restart.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage)
      : _themeMode = _decode(_storage.getString(StorageKeys.themeMode));

  final LocalStorage _storage;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.setString(StorageKeys.themeMode, _encode(mode));
  }

  /// Used by the dark mode switch on the Profile screen.
  Future<void> setDark(bool value) {
    return setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  static ThemeMode _decode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}