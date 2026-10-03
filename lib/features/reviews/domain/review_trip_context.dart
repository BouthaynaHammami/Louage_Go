import '../../../models/review.dart';

class ReviewTripContext {
  final bool eligible;
  final String driverId;
  final Review? existingReview;
  final bool canEditReview;

  const ReviewTripContext({
    required this.eligible,
    required this.driverId,
    this.existingReview,
    this.canEditReview = false,
  });
}
