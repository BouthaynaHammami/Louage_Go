import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_service.dart';
import '../../models/app_user.dart';
import 'data/auth_repository_impl.dart';
import 'domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);

final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  final sessionChanges = HiveService.session.watch(key: 'current');

  yield await repository.currentUser();
  await for (final _ in sessionChanges) {
    yield await repository.currentUser();
  }
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AppUser?> {
  late AuthRepository _repository;

  @override
  Future<AppUser?> build() {
    _repository = ref.watch(authRepositoryProvider);
    return _repository.currentUser();
  }

  Future<AppUser> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) => _run(
    () => _repository.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      role: role,
    ),
  );

  Future<AppUser> login({required String email, required String password}) =>
      _run(() => _repository.login(email: email, password: password));

  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      await _repository.logout();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<String> resetPassword(String email) =>
      _repository.resetPassword(email);

  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) => _repository.completePasswordReset(
    email: email,
    code: code,
    newPassword: newPassword,
  );

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await _repository.deleteAccount();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AppUser> _run(Future<AppUser> Function() action) async {
    state = const AsyncLoading();
    try {
      final user = await action();
      state = AsyncData(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
