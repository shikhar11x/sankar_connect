import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/local_storage.dart';
import '../models/app_user.dart';

/// Demo authentication state.
///
/// IMPORTANT: this is NOT real server authentication. Accounts are created
/// and checked locally against SharedPreferences. A short artificial delay
/// is added so loading states can be seen in the UI.
///
/// Persisted data:
/// * [StorageKeys.isLoggedIn]       - whether a session is active
/// * [StorageKeys.currentUser]      - the active user's profile (JSON)
/// * [StorageKeys.registeredUsers]  - all demo accounts (JSON strings)
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage) {
    _currentUser = _restoreSession();
  }

  static const Duration _simulatedDelay = Duration(milliseconds: 800);

  final LocalStorage _storage;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  /// Creates a demo account and signs the user in. Returns `true` on success.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _startLoading();
    await Future<void>.delayed(_simulatedDelay);

    final String normalizedEmail = _normalize(email);
    final List<DemoAccount> accounts = _readAccounts();

    final bool exists = accounts.any(
      (DemoAccount account) => _normalize(account.user.email) == normalizedEmail,
    );
    if (exists) {
      return _fail('An account with this email already exists. Please log in.');
    }

    final AppUser user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      email: normalizedEmail,
    );
    accounts.add(DemoAccount(user: user, password: password));

    await _writeAccounts(accounts);
    await _saveSession(user);

    _currentUser = user;
    _stopLoading();
    return true;
  }

  /// Checks credentials against locally stored accounts.
  /// Returns `true` on success.
  Future<bool> login({required String email, required String password}) async {
    _startLoading();
    await Future<void>.delayed(_simulatedDelay);

    final String normalizedEmail = _normalize(email);
    final List<DemoAccount> accounts = _readAccounts();

    DemoAccount? match;
    for (final DemoAccount account in accounts) {
      if (_normalize(account.user.email) == normalizedEmail) {
        match = account;
        break;
      }
    }

    if (match == null) {
      return _fail('No account found for this email. Please sign up first.');
    }
    if (match.password != password) {
      return _fail('Incorrect password. Please try again.');
    }

    await _saveSession(match.user);
    _currentUser = match.user;
    _stopLoading();
    return true;
  }

  /// Updates the name and phone of the signed-in user (email is fixed).
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final AppUser? current = _currentUser;
    if (current == null) return;

    final AppUser updated = current.copyWith(
      name: name.trim(),
      phone: phone.trim(),
    );

    final List<DemoAccount> accounts = _readAccounts().map((
      DemoAccount account,
    ) {
      return account.user.id == updated.id
          ? account.copyWith(user: updated)
          : account;
    }).toList();

    await _writeAccounts(accounts);
    await _saveSession(updated);

    _currentUser = updated;
    notifyListeners();
  }

  /// Ends the session. Accounts stay stored so the user can log in again.
  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;
    await _storage.setBool(StorageKeys.isLoggedIn, false);
    await _storage.remove(StorageKeys.currentUser);
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  AppUser? _restoreSession() {
    if (!_storage.getBool(StorageKeys.isLoggedIn)) return null;
    final String? raw = _storage.getString(StorageKeys.currentUser);
    if (raw == null) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return AppUser.fromJson(decoded);
    } on Object {
      // Corrupt data: treat as signed out.
    }
    return null;
  }

  Future<void> _saveSession(AppUser user) async {
    await _storage.setBool(StorageKeys.isLoggedIn, true);
    await _storage.setString(StorageKeys.currentUser, jsonEncode(user.toJson()));
  }

  List<DemoAccount> _readAccounts() {
    final List<DemoAccount> accounts = <DemoAccount>[];
    for (final String raw in _storage.getStringList(
      StorageKeys.registeredUsers,
    )) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          accounts.add(DemoAccount.fromJson(decoded));
        }
      } on Object {
        // Skip an unreadable entry instead of breaking every login.
      }
    }
    return accounts;
  }

  Future<void> _writeAccounts(List<DemoAccount> accounts) {
    return _storage.setStringList(
      StorageKeys.registeredUsers,
      accounts
          .map((DemoAccount account) => jsonEncode(account.toJson()))
          .toList(),
    );
  }

  String _normalize(String email) => email.trim().toLowerCase();

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  bool _fail(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
    return false;
  }
}