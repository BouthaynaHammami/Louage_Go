enum ReviewExceptionCode {
  notEligible,
  alreadyReviewed,
  invalidRating,
  invalidComment,
  reviewNotFound,
  editingWindowExpired,
  signInRequired,
}

class ReviewException implements Exception {
  final ReviewExceptionCode code;

  const ReviewException(this.code);
}
