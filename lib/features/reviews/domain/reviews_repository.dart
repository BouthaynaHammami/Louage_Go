import '../../../models/review.dart';
import 'driver_review.dart';
import 'review_summary.dart';
import 'review_trip_context.dart';

abstract interface class ReviewsRepository {
  Future<Review> submitReview({
    required String userId,
    required String tripId,
    required String driverId,
    required int rating,
    required String comment,
  });

  Future<Review> updateReview({
    required String userId,
    required String reviewId,
    required int rating,
    required String comment,
  });

  Future<void> deleteReview({
    required String userId,
    required String reviewId,
  });

  Stream<List<DriverReview>> watchDriverReviews(String driverId);

  Stream<ReviewSummary> watchDriverSummary(String driverId);

  Future<Review?> myReviewForTrip(String userId, String tripId);

  Future<ReviewTripContext?> reviewContext(String userId, String tripId);

  Future<void> reportReview({
    required String userId,
    required String reviewId,
  });
}
