import 'dart:async';

import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/booking.dart';
import '../../../models/driver_profile.dart';
import '../../../models/louage.dart';
import '../../../models/report.dart';
import '../../../models/review.dart';
import '../../../models/trip.dart';
import '../domain/driver_review.dart';
import '../domain/review_eligibility.dart';
import '../domain/review_exception.dart';
import '../domain/review_summary.dart';
import '../domain/review_trip_context.dart';
import '../domain/reviews_repository.dart';
import 'hive_review_eligibility.dart';

class HiveReviewsRepository implements ReviewsRepository {
  HiveReviewsRepository({
    Box<Map>? reviewsBox,
    Box<Map>? driversBox,
    Box<Map>? usersBox,
    Box<Map>? tripsBox,
    Box<Map>? louagesBox,
    Box<Map>? bookingsBox,
    Box<Map>? reportsBox,
    ReviewEligibility? eligibility,
    DateTime Function()? now,
  }) : _reviewsBox = reviewsBox ?? HiveService.reviews,
       _driversBox = driversBox ?? HiveService.drivers,
       _usersBox = usersBox ?? HiveService.users,
       _tripsBox = tripsBox ?? HiveService.trips,
       _louagesBox = louagesBox ?? HiveService.louages,
       _bookingsBox = bookingsBox ?? HiveService.bookings,
       _reportsBox = reportsBox ?? HiveService.reports,
       _now = now ?? DateTime.now,
       _eligibility =
           eligibility ??
           HiveReviewEligibility(
             bookingsBox: bookingsBox,
             tripsBox: tripsBox,
           );

  static const _uuid = Uuid();
  static const _editableFor = Duration(hours: 24);

  final Box<Map> _reviewsBox;
  final Box<Map> _driversBox;
  final Box<Map> _usersBox;
  final Box<Map> _tripsBox;
  final Box<Map> _louagesBox;
  final Box<Map> _bookingsBox;
  final Box<Map> _reportsBox;
  final ReviewEligibility _eligibility;
  final DateTime Function() _now;

  @override
  Future<Review> submitReview({
    required String userId,
    required String tripId,
    required String driverId,
    required int rating,
    required String comment,
  }) async {
    _validateUser(userId);
    _validateRating(rating);
    final cleanComment = _cleanComment(comment);
    final trip = _tripFor(tripId);
    final louageMap = _louagesBox.get(trip.louageId);
    final actualDriverId = louageMap == null
        ? ''
        : Louage.fromMap(louageMap).driverId;
    if (!await _eligibility.canReview(userId, tripId) ||
        actualDriverId.isEmpty ||
        actualDriverId != driverId) {
      throw const ReviewException(ReviewExceptionCode.notEligible);
    }

    final key = _reviewKey(userId, tripId);
    final hasExistingReview = _reviewsBox.values
        .map(Review.fromMap)
        .any((review) => review.userId == userId && review.tripId == tripId);
    if (_reviewsBox.containsKey(key) || hasExistingReview) {
      throw const ReviewException(ReviewExceptionCode.alreadyReviewed);
    }
    final review = Review(
      id: key,
      userId: userId,
      driverId: driverId,
      tripId: tripId,
      bookingId: _eligibleBookingId(userId, tripId),
      rating: rating.toDouble(),
      comment: cleanComment,
      createdAt: _now().toIso8601String(),
    );
    await _reviewsBox.put(key, review.toMap());
    await _recalculateDriver(driverId);
    return review;
  }

  @override
  Future<Review> updateReview({
    required String userId,
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    _validateUser(userId);
    _validateRating(rating);
    final cleanComment = _cleanComment(comment);
    final stored = _reviewsBox.get(reviewId);
    if (stored == null) {
      throw const ReviewException(ReviewExceptionCode.reviewNotFound);
    }
    final previous = Review.fromMap(stored);
    if (previous.userId != userId) {
      throw const ReviewException(ReviewExceptionCode.reviewNotFound);
    }
    _ensureEditable(previous);
    final updated = previous.copyWith(
      rating: rating.toDouble(),
      comment: cleanComment,
    );
    await _reviewsBox.put(reviewId, updated.toMap());
    await _recalculateDriver(previous.driverId);
    return updated;
  }

  @override
  Future<void> deleteReview({
    required String userId,
    required String reviewId,
  }) async {
    _validateUser(userId);
    final stored = _reviewsBox.get(reviewId);
    if (stored == null) {
      throw const ReviewException(ReviewExceptionCode.reviewNotFound);
    }
    final review = Review.fromMap(stored);
    if (review.userId != userId) {
      throw const ReviewException(ReviewExceptionCode.reviewNotFound);
    }
    _ensureEditable(review);
    await _reviewsBox.delete(reviewId);
    await _recalculateDriver(review.driverId);
  }

  @override
  Stream<List<DriverReview>> watchDriverReviews(String driverId) =>
      Stream<List<DriverReview>>.multi((controller) {
        void reload() {
          try {
            controller.add(_readDriverReviews(driverId));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscriptions = [
          _reviewsBox.watch().listen((_) => reload()),
          _usersBox.watch().listen((_) => reload()),
        ];
        controller.onCancel = () async {
          await Future.wait(
            subscriptions.map((subscription) => subscription.cancel()),
          );
        };
        reload();
      });

  @override
  Stream<ReviewSummary> watchDriverSummary(String driverId) =>
      Stream<ReviewSummary>.multi((controller) {
        void reload() {
          try {
            controller.add(_summaryFor(driverId));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscription = _reviewsBox.watch().listen((_) => reload());
        controller.onCancel = subscription.cancel;
        reload();
      });

  @override
  Future<Review?> myReviewForTrip(String userId, String tripId) async {
    final map = _reviewsBox.get(_reviewKey(userId, tripId));
    if (map != null) return Review.fromMap(map);
    return _reviewsBox.values
        .map(Review.fromMap)
        .where((review) => review.userId == userId && review.tripId == tripId)
        .firstOrNull;
  }

  @override
  Future<ReviewTripContext?> reviewContext(String userId, String tripId) async {
    final tripMap = _tripsBox.get(tripId);
    if (tripMap == null) return null;
    final trip = Trip.fromMap(tripMap);
    final louageMap = _louagesBox.get(trip.louageId);
    final driverId = louageMap == null
        ? ''
        : Louage.fromMap(louageMap).driverId;
    if (driverId.isEmpty) return null;
    final existingReview = await myReviewForTrip(userId, tripId);
    return ReviewTripContext(
      eligible: await _eligibility.canReview(userId, tripId),
      driverId: driverId,
      existingReview: existingReview,
      canEditReview:
          existingReview != null && _isWithinEditingWindow(existingReview),
    );
  }

  @override
  Future<void> reportReview({
    required String userId,
    required String reviewId,
  }) async {
    _validateUser(userId);
    final reviewMap = _reviewsBox.get(reviewId);
    if (reviewMap == null) {
      throw const ReviewException(ReviewExceptionCode.reviewNotFound);
    }
    final review = Review.fromMap(reviewMap);
    final timestamp = _now().toIso8601String();
    final report = Report(
      id: _uuid.v4(),
      reporterId: userId,
      targetId: review.id,
      targetType: 'review',
      reason: 'review',
      description: 'Reported review ${review.id}',
      status: 'open',
      createdAt: timestamp,
      authorId: userId,
      tripId: review.tripId,
      type: 'review',
      subject: 'review',
      category: 'review',
      updatedAt: timestamp,
    );
    await _reportsBox.put(report.id, report.toMap());
  }

  List<DriverReview> _readDriverReviews(String driverId) {
    final reviews = _reviewsBox.values
        .map(Review.fromMap)
        .where(
          (review) =>
              review.driverId == driverId &&
              review.rating >= 1 &&
              review.rating <= 5,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews
        .map(
          (review) => DriverReview(
            review: review,
            authorDisplayName: _authorDisplayName(review.userId),
          ),
        )
        .toList();
  }

  ReviewSummary _summaryFor(String driverId) {
    final reviews = _reviewsBox.values
        .map(Review.fromMap)
        .where(
          (review) =>
              review.driverId == driverId &&
              review.rating >= 1 &&
              review.rating <= 5,
        )
        .toList();
    final ratingsByStar = reviews.map((review) => review.rating.round());
    final distribution = <int, int>{for (var star = 1; star <= 5; star++) star: 0};
    for (final rating in ratingsByStar) {
      distribution[rating] = distribution[rating]! + 1;
    }
    final average = reviews.isEmpty
        ? 0.0
        : (reviews.fold<double>(0, (sum, review) => sum + review.rating) /
                      reviews.length *
                      10)
                  .round() /
              10;
    return ReviewSummary(
      average: average,
      total: reviews.length,
      distribution: distribution,
    );
  }

  Future<void> _recalculateDriver(String driverId) async {
    final driver = _driversBox.get(driverId);
    final profile = driver == null
        ? DriverProfile(userId: driverId)
        : DriverProfile.fromMap(driver);
    final summary = _summaryFor(driverId);
    await _driversBox.put(
      driverId,
      profile
          .copyWith(
            ratingAverage: summary.average,
            reviewCount: summary.total,
          )
          .toMap(),
    );
  }

  String _authorDisplayName(String userId) {
    if (userId.isEmpty) return '';
    final user = _usersBox.get(userId);
    if (user == null) return '';
    final words = (user['name'] as String? ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words.first;
    return '${words.first} ${words.last.substring(0, 1).toUpperCase()}.';
  }

  Trip _tripFor(String tripId) {
    final map = _tripsBox.get(tripId);
    if (map == null) {
      throw const ReviewException(ReviewExceptionCode.notEligible);
    }
    return Trip.fromMap(map);
  }

  String _eligibleBookingId(String userId, String tripId) {
    return _bookingsBox.values
            .map(Booking.fromMap)
            .where(
              (booking) =>
                  booking.userId == userId &&
                  booking.tripId == tripId &&
                  booking.status.toLowerCase() != 'cancelled',
            )
            .firstOrNull
            ?.id ??
        '';
  }

  void _ensureEditable(Review review) {
    if (!_isWithinEditingWindow(review)) {
      throw const ReviewException(ReviewExceptionCode.editingWindowExpired);
    }
  }

  bool _isWithinEditingWindow(Review review) {
    final createdAt = DateTime.tryParse(review.createdAt);
    if (createdAt == null) return false;
    final age = _now().difference(createdAt);
    return !age.isNegative && age <= _editableFor;
  }

  static void _validateUser(String userId) {
    if (userId.trim().isEmpty) {
      throw const ReviewException(ReviewExceptionCode.signInRequired);
    }
  }

  static void _validateRating(int rating) {
    if (rating < 1 || rating > 5) {
      throw const ReviewException(ReviewExceptionCode.invalidRating);
    }
  }

  static String _cleanComment(String comment) {
    final cleaned = comment
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim()
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
    if (cleaned.length > 300) {
      throw const ReviewException(ReviewExceptionCode.invalidComment);
    }
    return cleaned;
  }

  static String _reviewKey(String userId, String tripId) =>
      'review_${Uri.encodeComponent(userId)}_${Uri.encodeComponent(tripId)}';
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
