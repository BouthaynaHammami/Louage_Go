// Intégration : flux complet passager → chauffeur avec le vrai HiveReviewsRepository
//
// Ce test utilise uniquement de vraies implémentations Hive sur un dossier temporaire.
// Aucun mock, aucune substitution — exactement comme en production.
//
// Scénario :
//   1. Le passager soumet un avis (4 étoiles).
//   2. Le chauffeur lit les avis, la moyenne et le compteur.
//   3. Un deuxième avis du même passager sur le même trajet est refusé.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/reviews/data/hive_reviews_repository.dart';
import 'package:louage_go/features/reviews/domain/review_exception.dart';
import 'package:louage_go/models/booking.dart';
import 'package:louage_go/models/driver_profile.dart';
import 'package:louage_go/models/louage.dart';
import 'package:louage_go/models/trip.dart';

void main() {
  late Directory tempDir;

  late Box<Map> reviewsBox;
  late Box<Map> driversBox;
  late Box<Map> usersBox;
  late Box<Map> tripsBox;
  late Box<Map> louagesBox;
  late Box<Map> bookingsBox;
  late Box<Map> reportsBox;

  late HiveReviewsRepository passengerRepo;
  late HiveReviewsRepository driverRepo;

  setUp(() async {
    // Dossier temporaire propre à chaque test, identique au comportement en production.
    tempDir = await Directory.systemTemp.createTemp('louagego_review_flow_');
    Hive.init(tempDir.path);

    reviewsBox  = await Hive.openBox<Map>('reviews');
    driversBox  = await Hive.openBox<Map>('drivers');
    usersBox    = await Hive.openBox<Map>('users');
    tripsBox    = await Hive.openBox<Map>('trips');
    louagesBox  = await Hive.openBox<Map>('louages');
    bookingsBox = await Hive.openBox<Map>('bookings');
    reportsBox  = await Hive.openBox<Map>('reports');

    // ── Données de démonstration ──────────────────────────────────────────
    await driversBox.put(
      'driver-1',
      const DriverProfile(userId: 'driver-1', matricule: '21TUN999').toMap(),
    );
    await usersBox.put('passenger-1', {
      'id': 'passenger-1',
      'name': 'Amira Trabelsi',
      'phone': '+21650000001',
      'email': 'amira@example.test',
    });
    await louagesBox.put(
      'louage-1',
      const Louage(id: 'louage-1', driverId: 'driver-1').toMap(),
    );
    await tripsBox.put(
      'trip-1',
      const Trip(id: 'trip-1', louageId: 'louage-1', status: 'arrived').toMap(),
    );
    await bookingsBox.put(
      'booking-1',
      const Booking(
        id: 'booking-1',
        userId: 'passenger-1',
        tripId: 'trip-1',
        status: 'confirmed',
      ).toMap(),
    );

    // Les deux repositories partagent les mêmes boxes Hive — comme en production
    // où un seul HiveService est initialisé à l'ouverture de l'app.
    final sharedBoxes = _SharedBoxes(
      reviews: reviewsBox,
      drivers: driversBox,
      users: usersBox,
      trips: tripsBox,
      louages: louagesBox,
      bookings: bookingsBox,
      reports: reportsBox,
    );

    passengerRepo = sharedBoxes.buildRepository();
    driverRepo    = sharedBoxes.buildRepository();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'passager note → chauffeur voit avis + moyenne + compteur corrects, '
    'puis 2e avis du même passager sur le même trajet est refusé',
    () async {
      // ── Étape 1 : le passager soumet son avis ─────────────────────────
      final review = await passengerRepo.submitReview(
        userId: 'passenger-1',
        tripId: 'trip-1',
        driverId: 'driver-1',
        rating: 4,
        comment: 'Trajet agréable, chauffeur ponctuel.',
      );

      expect(review.rating, 4.0);
      expect(review.userId, 'passenger-1');
      expect(review.driverId, 'driver-1');
      expect(review.tripId, 'trip-1');
      expect(review.comment, 'Trajet agréable, chauffeur ponctuel.');
      expect(review.id, isNotEmpty);

      // ── Étape 2 : le chauffeur lit ses avis via son propre repository ─
      final driverReviews =
          await driverRepo.watchDriverReviews('driver-1').first;

      expect(driverReviews, hasLength(1));
      final entry = driverReviews.single;
      expect(entry.review.id, review.id);
      expect(entry.review.rating, 4.0);
      expect(entry.review.comment, 'Trajet agréable, chauffeur ponctuel.');
      // Le prénom et l'initiale du nom sont visibles, mais jamais l'e-mail ni le téléphone.
      expect(entry.authorDisplayName, 'Amira T.');
      expect(entry.authorDisplayName, isNot(contains('amira@example.test')));
      expect(entry.authorDisplayName, isNot(contains('50000001')));

      // ── Étape 3 : vérifier la moyenne et le compteur ──────────────────
      final summary = await driverRepo.watchDriverSummary('driver-1').first;

      expect(summary.total, 1);
      expect(summary.average, 4.0);
      expect(summary.distribution[4], 1);
      expect(summary.distribution[5], 0);

      // La note est également persistée dans le profil chauffeur (Hive drivers box).
      final storedProfile = DriverProfile.fromMap(driversBox.get('driver-1')!);
      expect(storedProfile.reviewCount, 1);
      expect(storedProfile.ratingAverage, 4.0);

      // ── Étape 4 : un 2e avis du même passager sur le même trajet est refusé ─
      await expectLater(
        passengerRepo.submitReview(
          userId: 'passenger-1',
          tripId: 'trip-1',
          driverId: 'driver-1',
          rating: 2,
          comment: 'Changé d\'avis.',
        ),
        throwsA(
          isA<ReviewException>().having(
            (e) => e.code,
            'code',
            ReviewExceptionCode.alreadyReviewed,
          ),
        ),
      );

      // La collection Hive et la moyenne restent inchangées.
      expect(reviewsBox.length, 1);
      final summaryAfterRejection =
          await driverRepo.watchDriverSummary('driver-1').first;
      expect(summaryAfterRejection.total, 1);
      expect(summaryAfterRejection.average, 4.0);
    },
  );
}

// ── Helper — partage les mêmes boxes entre passengerRepo et driverRepo ───────

class _SharedBoxes {
  const _SharedBoxes({
    required this.reviews,
    required this.drivers,
    required this.users,
    required this.trips,
    required this.louages,
    required this.bookings,
    required this.reports,
  });

  final Box<Map> reviews;
  final Box<Map> drivers;
  final Box<Map> users;
  final Box<Map> trips;
  final Box<Map> louages;
  final Box<Map> bookings;
  final Box<Map> reports;

  HiveReviewsRepository buildRepository() => HiveReviewsRepository(
    reviewsBox: reviews,
    driversBox: drivers,
    usersBox: users,
    tripsBox: trips,
    louagesBox: louages,
    bookingsBox: bookings,
    reportsBox: reports,
    // Pas de NotificationRepository ici : les notifications sont optionnelles
    // dans le repository et ne font pas partie du flux d'intégration testé.
  );
}
