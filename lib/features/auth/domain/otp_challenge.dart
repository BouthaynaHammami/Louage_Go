enum OtpPurpose { register, login, changePhone, recover }

class OtpChallenge {
  const OtpChallenge({
    required this.id,
    required this.expiresAt,
    required this.resendAvailableAt,
    this.demoCode,
  });

  final String id;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;
  final String? demoCode;
}
