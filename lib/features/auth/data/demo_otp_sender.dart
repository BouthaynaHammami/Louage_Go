import '../domain/otp_sender.dart';
import '../domain/phone_number.dart';

class DemoOtpSender implements OtpSender {
  @override
  Future<String> send(PhoneNumber phone, String code) async => code;
}
