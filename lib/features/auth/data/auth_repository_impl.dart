import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/app_user.dart';
import '../domain/auth_exception.dart';
import '../domain/otp_challenge.dart';
import '../domain/auth_repository.dart';
import '../domain/otp_sender.dart';
import '../domain/phone_number.dart';
import 'demo_otp_sender.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    Box<Map>? usersBox,
    Box<Map>? sessionBox,
    Box<Map>? favoritesBox,
    Box<Map>? notificationsBox,
    Box<Map>? driversBox,
    Box<Map>? louagesBox,
    Box<Map>? bookingsBox,
    Box<Map>? reviewsBox,
    OtpSender? otpSender,
    DateTime Function()? now,
  }) : _usersBox = usersBox ?? HiveService.users,
       _sessionBox = sessionBox ?? HiveService.session,
       _favoritesBoxOverride = favoritesBox,
       _notificationsBoxOverride = notificationsBox,
       _driversBoxOverride = driversBox,
       _louagesBoxOverride = louagesBox,
       _bookingsBoxOverride = bookingsBox,
       _reviewsBoxOverride = reviewsBox,
       _otpSender = otpSender ?? DemoOtpSender(),
       _now = now ?? DateTime.now;

  static const _uuid = Uuid();
  static final Random _random = Random.secure();
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final Box<Map> _usersBox;
  final Box<Map> _sessionBox;
  final Box<Map>? _favoritesBoxOverride;
  final Box<Map>? _notificationsBoxOverride;
  final Box<Map>? _driversBoxOverride;
  final Box<Map>? _louagesBoxOverride;
  final Box<Map>? _bookingsBoxOverride;
  final Box<Map>? _reviewsBoxOverride;
  final OtpSender _otpSender;
  final DateTime Function() _now;
  final Map<String, String> _pendingResetCodes = {};
  final Map<String, _OtpState> _otpChallenges = {};
  final Map<String, String> _activeChallengeByPhone = {};

  @override
  Future<OtpChallenge> requestOtp(PhoneNumber phone, OtpPurpose purpose) async {
    final existingUser = _findUserByPhone(phone);
    if (purpose == OtpPurpose.register && existingUser != null) {
      throw const AuthException(AuthException.phoneAlreadyUsed);
    }
    if (purpose == OtpPurpose.login && existingUser == null) {
      throw const AuthException(AuthException.phoneNotRegistered);
    }
    if (purpose == OtpPurpose.recover &&
        (existingUser == null ||
            AppUser.fromMap(existingUser.value).passwordHash.isNotEmpty)) {
      throw const AuthException(AuthException.phoneNotRegistered);
    }

    final now = _now();
    final activeId = _activeChallengeByPhone[phone.canonical];
    final activeState = activeId == null ? null : _otpChallenges[activeId];
    if (activeState != null && now.isBefore(activeState.resendAvailableAt)) {
      throw const AuthException(AuthException.otpResendTooSoon);
    }
    if (activeId != null) _removeChallenge(activeId);

    final code = _random.nextInt(1000000).toString().padLeft(6, '0');
    final challengeId = _uuid.v4();
    final expiresAt = now.add(const Duration(minutes: 5));
    final resendAvailableAt = now.add(const Duration(seconds: 30));
    final demoCode = await _otpSender.send(phone, code);
    _otpChallenges[challengeId] = _OtpState(
      phone: phone,
      purpose: purpose,
      codeHash: _hashOtp(code),
      expiresAt: expiresAt,
      resendAvailableAt: resendAvailableAt,
    );
    _activeChallengeByPhone[phone.canonical] = challengeId;
    return OtpChallenge(
      id: challengeId,
      expiresAt: expiresAt,
      resendAvailableAt: resendAvailableAt,
      demoCode: demoCode,
    );
  }

  @override
  Future<void> verifyOtp(String challengeId, String code) async {
    final state = _otpChallenges[challengeId];
    if (state == null || state.verified) {
      throw const AuthException(AuthException.otpInvalid);
    }
    if (!_now().isBefore(state.expiresAt)) {
      _removeChallenge(challengeId);
      throw const AuthException(AuthException.otpExpired);
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code) ||
        _hashOtp(code) != state.codeHash) {
      state.attempts++;
      if (state.attempts >= 3) {
        _removeChallenge(challengeId);
        throw const AuthException(AuthException.otpTooManyAttempts);
      }
      throw const AuthException(AuthException.otpInvalid);
    }
    state.verified = true;
  }

  @override
  Future<AppUser> registerWithPhone({
    required String name,
    required PhoneNumber phone,
    required String role,
    String? email,
  }) async {
    _requireVerified(phone, OtpPurpose.register);
    if (!_isRegistrationRole(role)) {
      throw const AuthException(AuthException.invalidCredentials);
    }
    final normalizedEmail = email?.trim().toLowerCase() ?? '';
    if (normalizedEmail.isNotEmpty &&
        !_emailPattern.hasMatch(normalizedEmail)) {
      throw const AuthException(AuthException.invalidEmail);
    }
    _ensurePhoneAvailable(phone);
    if (normalizedEmail.isNotEmpty && _findUserEntry(normalizedEmail) != null) {
      throw const AuthException(AuthException.emailAlreadyUsed);
    }

    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      phone: phone.canonical,
      email: normalizedEmail,
      role: role,
      status: 'active',
      createdAt: _now().toIso8601String(),
      phoneVerified: true,
    );
    await _usersBox.put(user.id, user.toMap());
    await _setSession(user.id);
    _consumeVerified(phone);
    return _publicUser(user);
  }

  @override
  Future<AppUser> loginWithPhone(PhoneNumber phone) async {
    final challengeId = _activeChallengeByPhone[phone.canonical];
    final challenge = challengeId == null ? null : _otpChallenges[challengeId];
    final purpose = challenge?.purpose == OtpPurpose.recover
        ? OtpPurpose.recover
        : OtpPurpose.login;
    _requireVerified(phone, purpose);
    final entry = _findUserByPhone(phone);
    if (entry == null) {
      throw const AuthException(AuthException.phoneNotRegistered);
    }
    final user = AppUser.fromMap(entry.value);
    if (user.status == 'blocked') {
      throw const AuthException(AuthException.accountBlocked);
    }
    await _setSession(user.id);
    _consumeVerified(phone);
    return _publicUser(user);
  }

  @override
  Future<AppUser> changePhone(PhoneNumber phone) async {
    _requireVerified(phone, OtpPurpose.changePhone);
    final userId = _sessionBox.get('current')?['userId'];
    if (userId is! String) {
      throw const AuthException(AuthException.invalidCredentials);
    }
    final storedUser = _usersBox.get(userId);
    if (storedUser == null) {
      throw const AuthException(AuthException.invalidCredentials);
    }

    final existingPhoneUser = _findUserByPhone(phone);
    if (existingPhoneUser != null && existingPhoneUser.key != userId) {
      throw const AuthException(AuthException.phoneAlreadyUsed);
    }

    final user = AppUser.fromMap(storedUser)
        .copyWith(phone: phone.canonical, phoneVerified: true);
    await _usersBox.put(userId, user.toMap());
    _consumeVerified(phone);
    return _publicUser(user);
  }

  @override
  Future<AppUser> updateProfile({
    String? name,
    String? email,
    String? city,
    String? photo,
    String? language,
  }) async {
    final userId = _sessionBox.get('current')?['userId'];
    if (userId is! String) {
      throw const AuthException(AuthException.profileUnavailable);
    }
    final storedUser = _usersBox.get(userId);
    if (storedUser == null) {
      throw const AuthException(AuthException.profileUnavailable);
    }

    final normalizedEmail = email?.trim().toLowerCase();
    if (normalizedEmail != null &&
        normalizedEmail.isNotEmpty &&
        !_emailPattern.hasMatch(normalizedEmail)) {
      throw const AuthException(AuthException.invalidEmail);
    }
    if (normalizedEmail != null && normalizedEmail.isNotEmpty) {
      final existingEntry = _findUserEntry(normalizedEmail);
      if (existingEntry != null && existingEntry.key != userId) {
        throw const AuthException(AuthException.emailAlreadyUsed);
      }
    }
    if (language != null && !const {'ar', 'en', 'fr'}.contains(language)) {
      throw const AuthException(AuthException.invalidCredentials);
    }

    final current = AppUser.fromMap(storedUser);
    final updated = current.copyWith(
      name: name?.trim(),
      email: normalizedEmail,
      city: city?.trim(),
      photo: photo,
      language: language,
    );
    await _usersBox.put(userId, updated.toMap());
    return _publicUser(updated);
  }

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

    final normalizedPhone = PhoneNumber(phone).canonical;
    if (!_isRegistrationRole(role)) {
      throw const AuthException(AuthException.invalidCredentials);
    }
    for (final storedUser in _usersBox.values) {
      final storedEmail = (storedUser['email'] as String? ?? '')
          .trim()
          .toLowerCase();
      if (storedEmail == normalizedEmail) {
        throw const AuthException(AuthException.emailAlreadyUsed);
      }
      if (_canonicalStoredPhone(storedUser['phone'] as String? ?? '') ==
          normalizedPhone) {
        throw const AuthException(AuthException.phoneAlreadyUsed);
      }
    }

    final salt = generateSalt();
    final user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      phone: normalizedPhone,
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
    if (user.passwordHash.isEmpty ||
        user.salt.isEmpty ||
        user.passwordHash != hashPassword(password, user.salt)) {
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

    final driverProfile = _driversBox.get(userId);
    final matricule = driverProfile?['matricule'] as String? ?? '';

    for (final entry in _favoritesBox.toMap().entries) {
      if (_belongsTo(entry.value, userId)) {
        await _favoritesBox.delete(entry.key);
      }
    }
    for (final entry in _notificationsBox.toMap().entries) {
      if (_belongsTo(entry.value, userId)) {
        await _notificationsBox.delete(entry.key);
      }
    }
    for (final entry in _louagesBox.toMap().entries) {
      final louage = entry.value;
      if (louage['driverId']?.toString() == userId ||
          (matricule.isNotEmpty && louage['matricule'] == matricule)) {
        await _louagesBox.delete(entry.key);
      }
    }
    await _driversBox.delete(userId);
    for (final entry in _bookingsBox.toMap().entries) {
      if (!_belongsTo(entry.value, userId)) continue;
      final anonymized = Map<dynamic, dynamic>.from(entry.value)
        ..['userId'] = '';
      await _bookingsBox.put(entry.key, anonymized);
    }
    for (final entry in _reviewsBox.toMap().entries) {
      final review = entry.value;
      if (review['userId']?.toString() != userId &&
          review['driverId']?.toString() != userId) {
        continue;
      }
      final anonymized = Map<dynamic, dynamic>.from(review);
      if (anonymized['userId']?.toString() == userId) {
        anonymized['userId'] = '';
      }
      if (anonymized['driverId']?.toString() == userId) {
        anonymized['driverId'] = '';
      }
      await _reviewsBox.put(entry.key, anonymized);
    }
    await _usersBox.delete(userId);
    await logout();
  }

  Box<Map> get _favoritesBox => _favoritesBoxOverride ?? HiveService.favorites;
  Box<Map> get _notificationsBox =>
      _notificationsBoxOverride ?? HiveService.notifications;
  Box<Map> get _driversBox => _driversBoxOverride ?? HiveService.drivers;
  Box<Map> get _louagesBox => _louagesBoxOverride ?? HiveService.louages;
  Box<Map> get _bookingsBox => _bookingsBoxOverride ?? HiveService.bookings;
  Box<Map> get _reviewsBox => _reviewsBoxOverride ?? HiveService.reviews;

  static bool _belongsTo(Map<dynamic, dynamic> record, String userId) =>
      record['userId']?.toString() == userId;

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

  static String _hashOtp(String code) =>
      sha256.convert(utf8.encode(code)).toString();

  static bool _isRegistrationRole(String role) =>
      role == 'passenger' || role == 'driver';

  static String? _canonicalStoredPhone(String phone) {
    try {
      return PhoneNumber(phone).canonical;
    } on AuthException {
      return null;
    }
  }

  MapEntry<dynamic, Map>? _findUserByPhone(PhoneNumber phone) {
    for (final entry in _usersBox.toMap().entries) {
      if (_canonicalStoredPhone(entry.value['phone'] as String? ?? '') ==
          phone.canonical) {
        return MapEntry(entry.key, entry.value);
      }
    }
    return null;
  }

  void _ensurePhoneAvailable(PhoneNumber phone) {
    if (_findUserByPhone(phone) != null) {
      throw const AuthException(AuthException.phoneAlreadyUsed);
    }
  }

  void _requireVerified(PhoneNumber phone, OtpPurpose purpose) {
    final challengeId = _activeChallengeByPhone[phone.canonical];
    final state = challengeId == null ? null : _otpChallenges[challengeId];
    if (state == null ||
        !state.verified ||
        state.purpose != purpose ||
        !_now().isBefore(state.expiresAt)) {
      if (state != null && !_now().isBefore(state.expiresAt)) {
        _removeChallenge(challengeId!);
        throw const AuthException(AuthException.otpExpired);
      }
      throw const AuthException(AuthException.otpInvalid);
    }
  }

  void _consumeVerified(PhoneNumber phone) {
    final challengeId = _activeChallengeByPhone[phone.canonical];
    if (challengeId != null) _removeChallenge(challengeId);
  }

  void _removeChallenge(String challengeId) {
    final state = _otpChallenges.remove(challengeId);
    if (state != null &&
        _activeChallengeByPhone[state.phone.canonical] == challengeId) {
      _activeChallengeByPhone.remove(state.phone.canonical);
    }
  }

  static AppUser _publicUser(AppUser user) =>
      user.copyWith(passwordHash: '', salt: '');
}

class _OtpState {
  _OtpState({
    required this.phone,
    required this.purpose,
    required this.codeHash,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  final PhoneNumber phone;
  final OtpPurpose purpose;
  final String codeHash;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;
  int attempts = 0;
  bool verified = false;
}
