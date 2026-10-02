import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/auth/data/auth_repository_impl.dart';
import 'package:louage_go/features/auth/domain/auth_exception.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> usersBox;
  late Box<Map> sessionBox;
  late AuthRepositoryImpl repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('louagego_auth_test');
    Hive.init(tempDirectory.path);
    usersBox = await Hive.openBox<Map>('users');
    sessionBox = await Hive.openBox<Map>('session');
    repository = AuthRepositoryImpl(usersBox: usersBox, sessionBox: sessionBox);
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
