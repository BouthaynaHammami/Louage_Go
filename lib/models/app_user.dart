import 'model_map.dart';

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String photo;
  final String city;
  final String language;
  final String status;
  final String passwordHash;
  final String salt;
  final String createdAt;

  const AppUser({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.role = 'passenger',
    this.photo = '',
    this.city = '',
    this.language = '',
    this.status = 'active',
    this.passwordHash = '',
    this.salt = '',
    this.createdAt = '',
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? photo,
    String? city,
    String? language,
    String? status,
    String? passwordHash,
    String? salt,
    String? createdAt,
  }) =>
      AppUser(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        role: role ?? this.role,
        photo: photo ?? this.photo,
        city: city ?? this.city,
        language: language ?? this.language,
        status: status ?? this.status,
        passwordHash: passwordHash ?? this.passwordHash,
        salt: salt ?? this.salt,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'photo': photo,
        'city': city,
        'language': language,
        'status': status,
        'passwordHash': passwordHash,
        'salt': salt,
        'createdAt': createdAt,
      };

  factory AppUser.fromMap(Map<dynamic, dynamic> map) {
    final role = ModelMap.text(map, 'role', 'passenger');
    final status = ModelMap.text(map, 'status', 'active');
    return AppUser(
      id: ModelMap.text(map, 'id'),
      name: ModelMap.text(map, 'name'),
      phone: ModelMap.text(map, 'phone'),
      email: ModelMap.text(map, 'email'),
      role: const ['passenger', 'driver', 'admin'].contains(role)
          ? role
          : 'passenger',
      photo: ModelMap.text(map, 'photo'),
      city: ModelMap.text(map, 'city'),
      language: ModelMap.text(map, 'language'),
      status: const ['active', 'blocked'].contains(status) ? status : 'active',
      passwordHash: ModelMap.text(map, 'passwordHash'),
      salt: ModelMap.text(map, 'salt'),
      createdAt: ModelMap.date(map, 'createdAt'),
    );
  }
}