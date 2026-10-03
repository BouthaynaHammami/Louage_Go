import '../../../models/app_user.dart';
import 'otp_challenge.dart';
import 'phone_number.dart';

abstract interface class AuthRepository {
  Future<OtpChallenge> requestOtp(PhoneNumber phone, OtpPurpose purpose);

  Future<void> verifyOtp(String challengeId, String code);

  Future<AppUser> registerWithPhone({
    required String name,
    required PhoneNumber phone,
    required String role,
    String? email,
  });

  Future<AppUser> loginWithPhone(PhoneNumber phone);

  Future<AppUser> changePhone(PhoneNumber phone);

  Future<AppUser> updateProfile({
    String? name,
    String? email,
    String? city,
    String? photo,
    String? language,
  });

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
