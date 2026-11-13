/// The profile of a signed-in user.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
  });

  final String id;
  final String name;
  final String email;

  /// Optional. Empty string when the user has not provided one.
  final String phone;

  AppUser copyWith({String? name, String? phone}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

/// A locally stored demo account: a profile plus its password.
///
/// DEMO ONLY. There is no server in this project, so accounts live in
/// SharedPreferences on the device and the password is stored as plain text.
/// A production app would authenticate against a backend and keep only a
/// token in secure storage.
class DemoAccount {
  const DemoAccount({required this.user, required this.password});

  final AppUser user;
  final String password;

  DemoAccount copyWith({AppUser? user}) {
    return DemoAccount(user: user ?? this.user, password: password);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user': user.toJson(),
      'password': password,
    };
  }

  factory DemoAccount.fromJson(Map<String, dynamic> json) {
    return DemoAccount(
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      password: json['password'] as String? ?? '',
    );
  }
}