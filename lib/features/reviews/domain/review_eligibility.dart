abstract interface class ReviewEligibility {
  Future<bool> canReview(String userId, String tripId);
}
