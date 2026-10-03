import 'auth_exception.dart';

class PhoneNumber {
  factory PhoneNumber(String input) {
    final value = input.trim();
    if (value.isEmpty ||
        !RegExp(r'^\+?[0-9\s().-]+$').hasMatch(value) ||
        (value.startsWith('+') && !value.startsWith('+216'))) {
      throw const AuthException(AuthException.invalidPhone);
    }

    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('216')) {
      digits = digits.substring(3);
    }
    if (digits.length != 8 || !RegExp(r'^[2459]\d{7}$').hasMatch(digits)) {
      throw const AuthException(AuthException.invalidPhone);
    }

    return PhoneNumber._('+216$digits');
  }

  const PhoneNumber._(this.canonical);

  final String canonical;

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber && other.canonical == canonical;

  @override
  int get hashCode => canonical.hashCode;

  @override
  String toString() => canonical;
}
