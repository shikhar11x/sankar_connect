import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences].
///
/// All providers talk to this class instead of SharedPreferences directly,
/// which keeps persistence logic in one place and easy to explain.
class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Creates an instance after SharedPreferences has finished loading.
  static Future<LocalStorage> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  List<String> getStringList(String key) {
    return List<String>.of(_prefs.getStringList(key) ?? <String>[]);
  }

  Future<bool> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  Future<bool> remove(String key) => _prefs.remove(key);
}