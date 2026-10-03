import 'package:hive_ce/hive.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/booking.dart';
import '../../../models/trip.dart';
import '../domain/review_eligibility.dart';

class HiveReviewEligibility implements ReviewEligibility {
  HiveReviewEligibility({
    Box<Map>? bookingsBox,
    Box<Map>? tripsBox,
  }) : _bookingsBox = bookingsBox ?? HiveService.bookings,
       _tripsBox = tripsBox ?? HiveService.trips;

  final Box<Map> _bookingsBox;
  final Box<Map> _tripsBox;

  @override
  Future<bool> canReview(String userId, String tripId) async {
    if (userId.trim().isEmpty || tripId.trim().isEmpty) return false;
    final tripMap = _tripsBox.get(tripId);
    if (tripMap == null || Trip.fromMap(tripMap).status != 'arrived') {
      return false;
    }
    return _bookingsBox.values
        .map(Booking.fromMap)
        .any(
          (booking) =>
              booking.userId == userId &&
              booking.tripId == tripId &&
              booking.status.toLowerCase() != 'cancelled',
        );
  }
}
