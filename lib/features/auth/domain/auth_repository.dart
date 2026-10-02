import '../../../models/app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  });

  Future<AppUser> login({required String email, required String password});

  Future<void> logout();

  Future<AppUser?> currentUser();

  Future<String?> currentRole();

  Future<String> resetPassword(String email);

  Future<void> completePasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> deleteAccount();
}
