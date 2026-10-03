import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_reviews_repository.dart';
import '../../domain/driver_review.dart';
import '../../domain/review_summary.dart';
import '../../domain/review_trip_context.dart';
import '../../domain/reviews_repository.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => HiveReviewsRepository(),
);

final driverReviewsProvider =
    StreamProvider.autoDispose.family<List<DriverReview>, String>(
      (ref, driverId) =>
          ref.watch(reviewsRepositoryProvider).watchDriverReviews(driverId),
    );

final driverReviewSummaryProvider =
    StreamProvider.autoDispose.family<ReviewSummary, String>(
      (ref, driverId) =>
          ref.watch(reviewsRepositoryProvider).watchDriverSummary(driverId),
    );

final reviewTripContextProvider =
    FutureProvider.autoDispose.family<ReviewTripContext?, (String, String)>(
      (ref, args) => ref
          .watch(reviewsRepositoryProvider)
          .reviewContext(args.$1, args.$2),
    );

final reviewControllerProvider =
    AsyncNotifierProvider<ReviewController, void>(ReviewController.new);

class ReviewController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submit({
    required String userId,
    required String tripId,
    required String driverId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(reviewsRepositoryProvider).submitReview(
        userId: userId,
        tripId: tripId,
        driverId: driverId,
        rating: rating,
        comment: comment,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateReview({
    required String userId,
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(reviewsRepositoryProvider).updateReview(
        userId: userId,
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
