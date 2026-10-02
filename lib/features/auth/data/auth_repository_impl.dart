import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({Box<Map>? usersBox, Box<Map>? sessionBox})
    : _usersBox = usersBox ?? HiveService.users,
      _sessionBox = sessionBox ?? HiveService.session;

  static const _uuid = Uuid();
  static final Random _random = Random.secure();
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final Box<Map> _usersBox;
  final Box<Map> _sessionBox;
  final Map<String, String> _pendingResetCodes = {};

  static String generateSalt() =>
      base64Url.encode(List<int>.generate(32, (_) => _random.nextInt(256)));

  static String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  @override
  Future<AppUser> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      throw const AuthException(AuthException.invalidEmail);
    }
    if (password.length < 6) {
      throw const AuthException(AuthException.weakPassword);
    }

    final normalizedPhone = _normalizePhone(phone);
    for (final storedUser in _usersBox.values) {
      final storedEmail = (storedUser['email'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (storedEmail == normalizedEmail) {
        throw const AuthException(AuthException.emailAlreadyUsed);
      }
      if (normalizedPhone.isNotEmpty &&
          _normalizePhone(storedUser['phone'] as String? ?? '') ==
              normalizedPhone) {
        throw const AuthException(AuthException.phoneAlreadyUsed);
      }
    }

    final salt = generateSalt();
    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      phone: phone.trim(),
      email: normalizedEmail,
      role: role,
      status: 'active',
      passwordHash: hashPassword(password, salt),
      salt: salt,
      createdAt: DateTime.now().toIso8601String(),
    );
    await _usersBox.put(user.id, user.toMap());
    await _setSession(user.id);
    return _publicUser(user);
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      throw const AuthException(AuthException.invalidEmail);
    }

    Map<dynamic, dynamic>? storedData;
    for (final entry in _usersBox.toMap().entries) {
      final storedEmail = (entry.value['email'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (storedEmail == normalizedEmail) {
        storedData = entry.value;
        break;
      }
    }
    if (storedData == null) {
      throw const AuthException(AuthException.invalidCredentials);
    }

    final user = AppUser.fromMap(storedData);
    if (user.passwordHash != hashPassword(password, user.salt)) {
      throw const AuthException(AuthException.invalidCredentials);
    }
    if (user.status == 'blocked') {
      throw const AuthException(AuthException.accountBlocked);
    }

    await _setSession(user.id);
    return _publicUser(user);
  }

  @override
  Future<void> logout() => _sessionBox.delete('current');

  @override
  Future<AppUser?> currentUser() async {
    final userId = _sessionBox.get('current')?['userId'];
    if (userId is! String) return null;

    final storedData = _usersBox.get(userId);
    if (storedData == null) return null;

    final user = AppUser.fromMap(storedData);
    if (user.status == 'blocked') {
      await logout();
      return null;
    }
    return _publicUser(user);
  }

  @override
  Future<String?> currentRole() async => (await currentUser())?.role;

  @override
  Future<String> resetPassword(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      throw const AuthException(AuthException.invalidEmail);
    }
    if (_findUserEntry(normalizedEmail) == null) {
      throw const AuthException(AuthException.invalidCredentials);
    }

    final code = _random.nextInt(1000000).toString().padLeft(6, '0');
    _pendingResetCodes[normalizedEmail] = code;
    return code;
  }

  @override
  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(normalizedEmail)) {
      throw const AuthException(AuthException.invalidEmail);
    }
    if (newPassword.length < 6) {
      throw const AuthException(AuthException.weakPassword);
    }
    if (_pendingResetCodes[normalizedEmail] != code.trim()) {
      throw const AuthException(AuthException.invalidResetCode);
    }

    final entry = _findUserEntry(normalizedEmail);
    if (entry == null) {
      throw const AuthException(AuthException.invalidCredentials);
    }

    final user = AppUser.fromMap(entry.value);
    final salt = generateSalt();
    await _usersBox.put(
      user.id,
      user
          .copyWith(passwordHash: hashPassword(newPassword, salt), salt: salt)
          .toMap(),
    );
    _pendingResetCodes.remove(normalizedEmail);
  }

  @override
  Future<void> deleteAccount() async {
    final userId = _sessionBox.get('current')?['userId'];
    if (userId is! String) return;
    await _usersBox.delete(userId);
    await logout();
  }

  Future<void> _setSession(String userId) =>
      _sessionBox.put('current', {'userId': userId});

  MapEntry<dynamic, Map>? _findUserEntry(String normalizedEmail) {
    for (final entry in _usersBox.toMap().entries) {
      final storedEmail = (entry.value['email'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (storedEmail == normalizedEmail) {
        return MapEntry(entry.key, entry.value);
      }
    }
    return null;
  }

  static String _normalizePhone(String phone) =>
      phone.replaceAll(RegExp(r'\D'), '');

  static AppUser _publicUser(AppUser user) =>
      user.copyWith(passwordHash: '', salt: '');
}
