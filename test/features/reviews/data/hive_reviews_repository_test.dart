import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/reviews/data/hive_review_eligibility.dart';
import 'package:louage_go/features/reviews/data/hive_reviews_repository.dart';
import 'package:louage_go/features/reviews/domain/review_exception.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/review.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory directory;
  late Box<Map> reviews;
  late Box<Map> drivers;
  late Box<Map> users;
  late Box<Map> trips;
  late Box<Map> louages;
  late Box<Map> bookings;
  late Box<Map> reports;
  late DateTime now;
  late HiveReviewsRepository repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('louagego_reviews_test');
    Hive.init(directory.path);
    reviews = await Hive.openBox<Map>('reviews');
    drivers = await Hive.openBox<Map>('drivers');
    users = await Hive.openBox<Map>('users');
    trips = await Hive.openBox<Map>('trips');
    louages = await Hive.openBox<Map>('louages');
    bookings = await Hive.openBox<Map>('bookings');
    reports = await Hive.openBox<Map>('reports');
    now = DateTime(2026, 10, 3, 12);
    await drivers.put(
      'driver-1',
      const DriverProfile(userId: 'driver-1').toMap(),
    );
    await users.put('user-1', {
      'id': 'user-1',
      'name': 'Jane Doe',
      'phone': '+21620000001',
      'email': 'jane@example.test',
    });
    await louages.put(
      'louage-1',
      const Louage(id: 'louage-1', driverId: 'driver-1').toMap(),
    );
    await trips.put(
      'trip-1',
      const Trip(id: 'trip-1', louageId: 'louage-1', status: 'arrived').toMap(),
    );
    await bookings.put(
      'booking-1',
      const Booking(
        id: 'booking-1',
        userId: 'user-1',
        tripId: 'trip-1',
        status: 'confirmed',
      ).toMap(),
    );
    repository = HiveReviewsRepository(
      reviewsBox: reviews,
      driversBox: drivers,
      usersBox: users,
      tripsBox: trips,
      louagesBox: louages,
      bookingsBox: bookings,
      reportsBox: reports,
      now: () => now,
    );
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'one review per user and trip is enforced with a stable record id',
    () async {
      final review = await _submit(repository, 'user-1', 5, ' Great trip ');
      expect(review.id, contains('trip-1'));
      expect(review.bookingId, 'booking-1');
      expect(review.comment, 'Great trip');
      await expectLater(
        _submit(repository, 'user-1', 4, 'Second review'),
        throwsA(
          isA<ReviewException>().having(
            (error) => error.code,
            'code',
            ReviewExceptionCode.alreadyReviewed,
          ),
        ),
      );
      expect(reviews.length, 1);
    },
  );

  test(
    'rating average, count and distribution recalculate on update and delete',
    () async {
      final first = await _submit(repository, 'user-1', 5, 'Excellent');
      await users.put('user-2', {'id': 'user-2', 'name': 'Alex Roe'});
      await bookings.put(
        'booking-2',
        const Booking(
          id: 'booking-2',
          userId: 'user-2',
          tripId: 'trip-1',
          status: 'confirmed',
        ).toMap(),
      );
      final second = await _submit(repository, 'user-2', 3, 'Good');

      var summary = await repository.watchDriverSummary('driver-1').first;
      expect(summary.average, 4);
      expect(summary.total, 2);
      expect(summary.distribution, {1: 0, 2: 0, 3: 1, 4: 0, 5: 1});
      expect(DriverProfile.fromMap(drivers.get('driver-1')!).reviewCount, 2);

      await repository.updateReview(
        userId: 'user-1',
        reviewId: first.id,
        rating: 1,
        comment: 'Updated',
      );
      summary = await repository.watchDriverSummary('driver-1').first;
      expect(summary.average, 2);
      expect(summary.distribution[1], 1);

      await repository.deleteReview(userId: 'user-2', reviewId: second.id);
      summary = await repository.watchDriverSummary('driver-1').first;
      expect(summary.average, 1);
      expect(summary.total, 1);
      expect(DriverProfile.fromMap(drivers.get('driver-1')!).reviewCount, 1);
    },
  );

  test('eligibility rejects a completed trip with no active booking', () async {
    await bookings.delete('booking-1');
    final eligibility = HiveReviewEligibility(
      bookingsBox: bookings,
      tripsBox: trips,
    );
    expect(await eligibility.canReview('user-1', 'trip-1'), isFalse);
    await expectLater(
      _submit(repository, 'user-1', 5, ''),
      throwsA(
        isA<ReviewException>().having(
          (error) => error.code,
          'code',
          ReviewExceptionCode.notEligible,
        ),
      ),
    );
    expect(reviews, isEmpty);
  });

  test(
    'cancelled booking and non-arrived trip are not review eligible',
    () async {
      await bookings.put(
        'booking-1',
        const Booking(
          id: 'booking-1',
          userId: 'user-1',
          tripId: 'trip-1',
          status: 'cancelled',
        ).toMap(),
      );
      final eligibility = HiveReviewEligibility(
        bookingsBox: bookings,
        tripsBox: trips,
      );
      expect(await eligibility.canReview('user-1', 'trip-1'), isFalse);

      await bookings.put(
        'booking-1',
        const Booking(
          id: 'booking-1',
          userId: 'user-1',
          tripId: 'trip-1',
          status: 'confirmed',
        ).toMap(),
      );
      await trips.put(
        'trip-1',
        const Trip(
          id: 'trip-1',
          louageId: 'louage-1',
          status: 'departed',
        ).toMap(),
      );
      expect(await eligibility.canReview('user-1', 'trip-1'), isFalse);
    },
  );

  test('review can only be changed during the first 24 hours', () async {
    final review = await _submit(repository, 'user-1', 4, '');
    expect(
      (await repository.reviewContext('user-1', 'trip-1'))?.canEditReview,
      isTrue,
    );
    now = now.add(const Duration(hours: 24, seconds: 1));
    expect(
      (await repository.reviewContext('user-1', 'trip-1'))?.canEditReview,
      isFalse,
    );
    await expectLater(
      repository.updateReview(
        userId: 'user-1',
        reviewId: review.id,
        rating: 5,
        comment: '',
      ),
      throwsA(
        isA<ReviewException>().having(
          (error) => error.code,
          'code',
          ReviewExceptionCode.editingWindowExpired,
        ),
      ),
    );
    await expectLater(
      repository.deleteReview(userId: 'user-1', reviewId: review.id),
      throwsA(isA<ReviewException>()),
    );
  });

  test('driver review display name never exposes email or phone', () async {
    await _submit(repository, 'user-1', 5, 'Nice');
    final result = await repository.watchDriverReviews('driver-1').first;
    expect(result.single.authorDisplayName, 'Jane D.');
    expect(result.single.authorDisplayName, isNot(contains('20000001')));
    expect(
      result.single.authorDisplayName,
      isNot(contains('jane@example.test')),
    );
  });

  test('review reports use the existing reports box without passenger contact data', () async {
    final review = await _submit(repository, 'user-1', 3, 'Needs review');
    await repository.reportReview(userId: 'user-2', reviewId: review.id);
    final report = reports.values.single;
    expect(report['type'], 'review');
    expect(report['targetId'], review.id);
    expect(report.containsKey('phone'), isFalse);
    expect(report.containsKey('email'), isFalse);
  });

  test('new model properties default cleanly when reading legacy records', () {
    expect(
      Review.fromMap({
        'id': 'legacy-review',
        'userId': 'user-1',
        'driverId': 'driver-1',
        'tripId': 'trip-1',
        'rating': 4,
      }).bookingId,
      isEmpty,
    );
    expect(
      DriverProfile.fromMap({'userId': 'driver-1'}).reviewCount,
      0,
    );
  });
}

Future<Review> _submit(
  HiveReviewsRepository repository,
  String userId,
  int rating,
  String comment,
) => repository.submitReview(
  userId: userId,
  tripId: 'trip-1',
  driverId: 'driver-1',
  rating: rating,
  comment: comment,
);
