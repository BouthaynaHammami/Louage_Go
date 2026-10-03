import '../../../models/review.dart';

class DriverReview {
  final Review review;
  final String authorDisplayName;

  const DriverReview({
    required this.review,
    required this.authorDisplayName,
  });
}
