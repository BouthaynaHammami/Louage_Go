import '../domain/otp_challenge.dart';
import '../domain/phone_number.dart';

class OtpArguments {
  const OtpArguments({
    required this.phone,
    required this.purpose,
    this.challenge,
    this.name,
    this.role,
    this.email,
  });

  final PhoneNumber phone;
  final OtpPurpose purpose;
  final OtpChallenge? challenge;
  final String? name;
  final String? role;
  final String? email;
}