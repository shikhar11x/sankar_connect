/// Form validators. Each returns an error message, or `null` when valid.
abstract final class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^[0-9]{10}$');

  static String? name(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your name';
    if (text.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your email';
    if (!_emailRegex.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Please enter your password';
    if (text.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final String text = value ?? '';
    if (text.isEmpty) return 'Please confirm your password';
    if (text != original) return 'Passwords do not match';
    return null;
  }

  /// Phone is optional: an empty value is valid, otherwise it must be
  /// exactly 10 digits.
  static String? optionalPhone(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!_phoneRegex.hasMatch(text)) return 'Enter a valid 10-digit number';
    return null;
  }
}
