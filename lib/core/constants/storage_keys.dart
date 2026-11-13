/// Central registry of every SharedPreferences key used in Sankar Connect.
///
/// Keeping keys in one place prevents typos and makes it easy to see
/// exactly what the app persists locally.
abstract final class StorageKeys {
  /// Whether a demo session is currently active.
  static const String isLoggedIn = 'is_logged_in';

  /// JSON of the currently logged-in user's profile.
  static const String currentUser = 'current_user';

  /// JSON list of demo accounts created via the Signup screen.
  static const String registeredUsers = 'registered_users';

  /// List of favourite product IDs.
  static const String favouriteIds = 'favourite_ids';

  /// Saved theme mode: 'light', 'dark' or 'system'.
  static const String themeMode = 'theme_mode';
}
