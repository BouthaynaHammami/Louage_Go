enum SupportExceptionCode {
  signInRequired,
  invalidCategory,
  invalidMessage,
  tooManyOpenRequests,
}

class SupportException implements Exception {
  const SupportException(this.code);

  final SupportExceptionCode code;
}
