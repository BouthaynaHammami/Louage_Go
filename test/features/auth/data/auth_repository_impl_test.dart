import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/auth/data/auth_repository_impl.dart';
import 'package:louage_go/features/auth/domain/auth_exception.dart';
import 'package:louage_go/features/auth/domain/otp_challenge.dart';
import 'package:louage_go/features/auth/domain/phone_number.dart';
import 'package:louage_go/models/app_user.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> usersBox;
  late Box<Map> sessionBox;
  late Box<Map> favoritesBox;
  late Box<Map> notificationsBox;
  late Box<Map> driversBox;
  late Box<Map> louagesBox;
  late Box<Map> bookingsBox;
  late Box<Map> reviewsBox;
  late AuthRepositoryImpl repository;
  late DateTime currentTime;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('louagego_auth_test');
    Hive.init(tempDirectory.path);
    usersBox = await Hive.openBox<Map>('users');
    sessionBox = await Hive.openBox<Map>('session');
    favoritesBox = await Hive.openBox<Map>('favorites');
    notificationsBox = await Hive.openBox<Map>('notifications');
    driversBox = await Hive.openBox<Map>('drivers');
    louagesBox = await Hive.openBox<Map>('louages');
    bookingsBox = await Hive.openBox<Map>('bookings');
    reviewsBox = await Hive.openBox<Map>('reviews');
    currentTime = DateTime(2026, 10, 3);
    repository = AuthRepositoryImpl(
      usersBox: usersBox,
      sessionBox: sessionBox,
      favoritesBox: favoritesBox,
      notificationsBox: notificationsBox,
      driversBox: driversBox,
      louagesBox: louagesBox,
      bookingsBox: bookingsBox,
      reviewsBox: reviewsBox,
      now: () => currentTime,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('register stores a salted hash and starts a session', () async {
    final user = await repository.register(
      name: 'Test User',
      phone: '+216 20 123 456',
      email: 'TEST@example.com',
      password: 'secret123',
      role: 'passenger',
    );
    final storedUser = usersBox.get(user.id)!;

    expect(user.email, 'test@example.com');
    expect(user.passwordHash, isEmpty);
    expect(storedUser['salt'], isNotEmpty);
    expect(storedUser['passwordHash'], isNot('secret123'));
    expect(sessionBox.get('current')?['userId'], user.id);
  });

  test('phone number inputs normalize to the Tunisian canonical form', () {
    expect(PhoneNumber('+216 20 000 001').canonical, '+21620000001');
    expect(PhoneNumber('0021620000001').canonical, '+21620000001');
    expect(PhoneNumber('20000001').canonical, '+21620000001');
    expect(() => PhoneNumber('30000001'), throwsA(isA<AuthException>()));
  });

  test('legacy users default phoneVerified to false', () {
    expect(AppUser.fromMap({'id': 'legacy-user'}).phoneVerified, isFalse);
  });

  test('OTP expires after five minutes', () async {
    final phone = PhoneNumber('20000011');
    final challenge = await repository.requestOtp(phone, OtpPurpose.register);
    currentTime = currentTime.add(const Duration(minutes: 5));

    await expectLater(
      repository.verifyOtp(challenge.id, challenge.demoCode!),
      throwsA(
        isA<AuthException>().having(
          (error) => error.code,
          'code',
          AuthException.otpExpired,
        ),
      ),
    );
  });

  test('third incorrect OTP attempt invalidates the challenge', () async {
    final challenge = await repository.requestOtp(
      PhoneNumber('20000012'),
      OtpPurpose.register,
    );
    final incorrectCode = challenge.demoCode == '000000' ? '000001' : '000000';

    for (var attempt = 0; attempt < 2; attempt++) {
      await expectLater(
        repository.verifyOtp(challenge.id, incorrectCode),
        throwsA(
          isA<AuthException>().having(
            (error) => error.code,
            'code',
            AuthException.otpInvalid,
          ),
        ),
      );
    }
    await expectLater(
      repository.verifyOtp(challenge.id, incorrectCode),
      throwsA(
        isA<AuthException>().having(
          (error) => error.code,
          'code',
          AuthException.otpTooManyAttempts,
        ),
      ),
    );
    await expectLater(
      repository.verifyOtp(challenge.id, challenge.demoCode!),
      throwsA(isA<AuthException>()),
    );
  });

  test('OTP resend is rejected during the first thirty seconds', () async {
    final phone = PhoneNumber('20000013');
    await repository.requestOtp(phone, OtpPurpose.register);

    await expectLater(
      repository.requestOtp(phone, OtpPurpose.register),
      throwsA(
        isA<AuthException>().having(
          (error) => error.code,
          'code',
          AuthException.otpResendTooSoon,
        ),
      ),
    );
  });

  test(
    'phone registration verifies OTP, canonicalizes and enforces uniqueness',
    () async {
      final phone = PhoneNumber('+216 20 000 014');
      final challenge = await repository.requestOtp(phone, OtpPurpose.register);
      await repository.verifyOtp(challenge.id, challenge.demoCode!);
      final user = await repository.registerWithPhone(
        name: 'Phone User',
        phone: phone,
        role: 'passenger',
      );

      expect(user.phone, '+21620000014');
      expect(user.phoneVerified, isTrue);
      expect(usersBox.get(user.id)?['passwordHash'], isEmpty);
      expect(usersBox.get(user.id)?['salt'], isEmpty);
      await expectLater(
        repository.requestOtp(
          PhoneNumber('0021620000014'),
          OtpPurpose.register,
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.code,
            'code',
            AuthException.phoneAlreadyUsed,
          ),
        ),
      );
    },
  );

  test('email login rejects accounts without a password hash', () async {
    await usersBox.put('phone-only', {
      'id': 'phone-only',
      'email': 'phone@example.com',
      'phone': '+21620000015',
      'passwordHash': '',
      'salt': '',
    });

    await expectLater(
      repository.login(email: 'phone@example.com', password: 'secret123'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.code,
          'code',
          AuthException.invalidCredentials,
        ),
      ),
    );
  });

  test(
    'resending after thirty seconds invalidates the previous challenge',
    () async {
      final phone = PhoneNumber('20000016');
      final first = await repository.requestOtp(phone, OtpPurpose.register);
      currentTime = currentTime.add(const Duration(seconds: 30));
      final second = await repository.requestOtp(phone, OtpPurpose.register);

      await expectLater(
        repository.verifyOtp(first.id, first.demoCode!),
        throwsA(isA<AuthException>()),
      );
      await repository.verifyOtp(second.id, second.demoCode!);
    },
  );

  test(
    'existing email and password demo-style account can still log in',
    () async {
      final salt = AuthRepositoryImpl.generateSalt();
      await usersBox.put('demo_passenger', {
        'id': 'demo_passenger',
        'name': 'Passager Demo',
        'phone': '20000003',
        'email': 'passager@louagego.tn',
        'role': 'passenger',
        'salt': salt,
        'passwordHash': AuthRepositoryImpl.hashPassword('Passenger123!', salt),
      });

      final user = await repository.login(
        email: 'passager@louagego.tn',
        password: 'Passenger123!',
      );

      expect(user.id, 'demo_passenger');
      expect(user.role, 'passenger');
    },
  );

  test('OTP login only succeeds for a registered canonical phone', () async {
    final salt = AuthRepositoryImpl.generateSalt();
    await usersBox.put('demo_driver', {
      'id': 'demo_driver',
      'name': 'Chauffeur Demo',
      'phone': '20000002',
      'email': 'chauffeur@louagego.tn',
      'role': 'driver',
      'salt': salt,
      'passwordHash': AuthRepositoryImpl.hashPassword('Driver123!', salt),
    });
    final phone = PhoneNumber('+216 20 000 002');
    final challenge = await repository.requestOtp(phone, OtpPurpose.login);
    await repository.verifyOtp(challenge.id, challenge.demoCode!);
    final user = await repository.loginWithPhone(phone);

    expect(user.id, 'demo_driver');
    expect(sessionBox.get('current')?['userId'], 'demo_driver');
  });

  test(
    'changing phone requires OTP and updates the signed-in account',
    () async {
      final registered = await repository.register(
        name: 'Phone Change User',
        phone: '20000017',
        email: 'change@example.com',
        password: 'secret123',
        role: 'passenger',
      );
      final newPhone = PhoneNumber('20000018');
      final challenge = await repository.requestOtp(
        newPhone,
        OtpPurpose.changePhone,
      );
      await repository.verifyOtp(challenge.id, challenge.demoCode!);

      final updated = await repository.changePhone(newPhone);

      expect(updated.id, registered.id);
      expect(updated.phone, '+21620000018');
      expect(updated.phoneVerified, isTrue);
      expect(sessionBox.get('current')?['userId'], registered.id);
    },
  );

  test(
    'changePhone rejects a number already owned by another account',
    () async {
      final first = await repository.register(
        name: 'First',
        phone: '20000021',
        email: 'first@example.com',
        password: 'secret123',
        role: 'passenger',
      );
      final second = await repository.register(
        name: 'Second',
        phone: '20000022',
        email: 'second@example.com',
        password: 'secret123',
        role: 'passenger',
      );
      expect(first.id, isNot(second.id));

      final existingPhone = PhoneNumber('20000021');
      final challenge = await repository.requestOtp(
        existingPhone,
        OtpPurpose.changePhone,
      );
      await repository.verifyOtp(challenge.id, challenge.demoCode!);

      await expectLater(
        repository.changePhone(existingPhone),
        throwsA(
          isA<AuthException>().having(
            (error) => error.code,
            'code',
            AuthException.phoneAlreadyUsed,
          ),
        ),
      );
      expect(usersBox.get(second.id)?['phone'], '+21620000022');
    },
  );

  test(
    'updateProfile validates email uniqueness and stores profile fields',
    () async {
      final owner = await repository.register(
        name: 'Owner',
        phone: '20000031',
        email: 'owner@example.com',
        password: 'secret123',
        role: 'passenger',
      );
      await repository.register(
        name: 'Other',
        phone: '20000032',
        email: 'other@example.com',
        password: 'secret123',
        role: 'passenger',
      );
      await expectLater(
        repository.updateProfile(email: 'owner@example.com'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.code,
            'code',
            AuthException.emailAlreadyUsed,
          ),
        ),
      );

      await repository.login(email: 'owner@example.com', password: 'secret123');
      final updated = await repository.updateProfile(
        name: '  Updated Owner ',
        email: ' UPDATED@Example.com ',
        city: 'Tunis',
        photo: '/documents/avatar.jpg',
        language: 'ar',
      );

      expect(updated.name, 'Updated Owner');
      expect(updated.email, 'updated@example.com');
      expect(updated.city, 'Tunis');
      expect(updated.photo, '/documents/avatar.jpg');
      expect(updated.language, 'ar');
      expect(usersBox.get(owner.id)?['language'], 'ar');
    },
  );

  test(
    'profile edits and avatar path survive closing and reopening Hive',
    () async {
      final avatar = File(
        '${tempDirectory.path}${Platform.pathSeparator}avatar.jpg',
      );
      await avatar.writeAsBytes([1, 2, 3, 4]);
      final registered = await repository.register(
        name: 'Old Name',
        phone: '20000042',
        email: 'old@example.com',
        password: 'secret123',
        role: 'passenger',
      );
      await repository.updateProfile(
        name: 'Amira Ben Salem',
        email: 'amira@example.com',
        city: 'Tunis',
        photo: avatar.path,
      );

      final newPhone = PhoneNumber('20000043');
      final challenge = await repository.requestOtp(
        newPhone,
        OtpPurpose.changePhone,
      );
      await repository.verifyOtp(challenge.id, challenge.demoCode!);
      await repository.changePhone(newPhone);
      await Hive.close();

      Hive.init(tempDirectory.path);
      final reopenedUsers = await Hive.openBox<Map>('users');
      final reopenedSession = await Hive.openBox<Map>('session');
      final restartedRepository = AuthRepositoryImpl(
        usersBox: reopenedUsers,
        sessionBox: reopenedSession,
      );
      final loadedUser = await restartedRepository.currentUser();

      expect(loadedUser?.id, registered.id);
      expect(loadedUser?.name, 'Amira Ben Salem');
      expect(loadedUser?.email, 'amira@example.com');
      expect(loadedUser?.phone, '+21620000043');
      expect(loadedUser?.city, 'Tunis');
      expect(loadedUser?.photo, avatar.path);
      expect(await File(loadedUser!.photo).readAsBytes(), [1, 2, 3, 4]);
    },
  );

  test('profile language persists across a new email login', () async {
    await repository.register(
      name: 'Language User',
      phone: '20000041',
      email: 'language@example.com',
      password: 'secret123',
      role: 'passenger',
    );
    await repository.updateProfile(language: 'en');
    await repository.logout();

    final loggedIn = await repository.login(
      email: 'language@example.com',
      password: 'secret123',
    );

    expect(loggedIn.language, 'en');
    expect((await repository.currentUser())?.language, 'en');
  });

  test('phone recovery OTP restores access to a phone-only account', () async {
    final phone = PhoneNumber('20000045');
    final registrationChallenge = await repository.requestOtp(
      phone,
      OtpPurpose.register,
    );
    await repository.verifyOtp(
      registrationChallenge.id,
      registrationChallenge.demoCode!,
    );
    await repository.registerWithPhone(
      name: 'Phone User',
      phone: phone,
      role: 'passenger',
    );
    await repository.logout();

    final recoveryChallenge = await repository.requestOtp(
      phone,
      OtpPurpose.recover,
    );
    await repository.verifyOtp(
      recoveryChallenge.id,
      recoveryChallenge.demoCode!,
    );
    final user = await repository.loginWithPhone(phone);

    expect(user.name, 'Phone User');
    expect((await repository.currentUser())?.phone, phone.canonical);
  });

  test(
    'deleteAccount cascades and anonymizes retained bookings and reviews',
    () async {
      final driver = await repository.register(
        name: 'Driver',
        phone: '20000051',
        email: 'driver@example.com',
        password: 'secret123',
        role: 'driver',
      );
      driversBox.put(driver.id, {'userId': driver.id, 'matricule': '123TU456'});
      louagesBox.put('owned-louage', {
        'id': 'owned-louage',
        'driverId': driver.id,
        'matricule': '123TU456',
      });
      louagesBox.put('other-louage', {
        'id': 'other-louage',
        'driverId': 'other-driver',
        'matricule': '654TU321',
      });
      favoritesBox.put('owned-favorite', {'userId': driver.id});
      favoritesBox.put('other-favorite', {'userId': 'other-user'});
      notificationsBox.put('owned-notification', {'userId': driver.id});
      bookingsBox.put('owned-booking', {
        'userId': driver.id,
        'tripId': 'historical-trip',
      });
      reviewsBox.put('author-review', {
        'userId': driver.id,
        'driverId': 'other-driver',
        'comment': 'Retained review',
      });
      reviewsBox.put('driver-review', {
        'userId': 'other-user',
        'driverId': driver.id,
        'comment': 'Retained driver review',
      });

      await repository.deleteAccount();

      expect(usersBox.containsKey(driver.id), isFalse);
      expect(driversBox.containsKey(driver.id), isFalse);
      expect(louagesBox.containsKey('owned-louage'), isFalse);
      expect(louagesBox.containsKey('other-louage'), isTrue);
      expect(favoritesBox.containsKey('owned-favorite'), isFalse);
      expect(favoritesBox.containsKey('other-favorite'), isTrue);
      expect(notificationsBox.containsKey('owned-notification'), isFalse);
      expect(bookingsBox.get('owned-booking'), {
        'userId': '',
        'tripId': 'historical-trip',
      });
      expect(reviewsBox.get('author-review')?['userId'], '');
      expect(reviewsBox.get('driver-review')?['driverId'], '');
      expect(reviewsBox.length, 2);
      expect(sessionBox.containsKey('current'), isFalse);
    },
  );

  test('currentUser returns the user immediately after registration', () async {
    final registered = await repository.register(
      name: 'Test User',
      phone: '20123456',
      email: 'test@example.com',
      password: 'secret123',
      role: 'passenger',
    );

    final currentUser = await repository.currentUser();

    expect(currentUser?.id, registered.id);
    expect(currentUser?.email, registered.email);
  });

  test('login verifies the salted hash and restores the session', () async {
    final registered = await repository.register(
      name: 'Test User',
      phone: '20123456',
      email: 'test@example.com',
      password: 'secret123',
      role: 'driver',
    );
    await repository.logout();

    final loggedIn = await repository.login(
      email: 'TEST@example.com',
      password: 'secret123',
    );

    expect(loggedIn.id, registered.id);
    expect(loggedIn.role, 'driver');
    expect(loggedIn.passwordHash, isEmpty);
    expect(sessionBox.get('current')?['userId'], registered.id);
    expect((await repository.currentUser())?.id, registered.id);
  });

  test(
    'password reset rejects a wrong code and stores the new password',
    () async {
      await repository.register(
        name: 'Test User',
        phone: '20123456',
        email: 'test@example.com',
        password: 'secret123',
        role: 'passenger',
      );
      await repository.logout();

      final code = await repository.resetPassword('test@example.com');
      await expectLater(
        repository.completePasswordReset(
          email: 'test@example.com',
          code: '000000',
          newPassword: 'updated123',
        ),
        throwsA(isA<AuthException>()),
      );

      await repository.completePasswordReset(
        email: 'test@example.com',
        code: code,
        newPassword: 'updated123',
      );
      final loggedIn = await repository.login(
        email: 'test@example.com',
        password: 'updated123',
      );

      expect(loggedIn.email, 'test@example.com');
      expect(
        () =>
            repository.login(email: 'test@example.com', password: 'secret123'),
        throwsA(isA<AuthException>()),
      );
    },
  );
}
