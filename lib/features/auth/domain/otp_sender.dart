import 'phone_number.dart';

abstract interface class OtpSender {
  Future<String?> send(PhoneNumber phone, String code);
}
