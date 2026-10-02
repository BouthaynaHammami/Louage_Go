import 'model_map.dart';

class Review {
  final String id;
  final String userId;
  final String driverId;
  final String tripId;
  final double rating;
  final String comment;
  final String createdAt;

  const Review({
    this.id = '',
    this.userId = '',
    this.driverId = '',
    this.tripId = '',
    this.rating = 0,
    this.comment = '',
    this.createdAt = '',
  });

  Review copyWith({
    String? id,
    String? userId,
    String? driverId,
    String? tripId,
    double? rating,
    String? comment,
    String? createdAt,
  }) =>
      Review(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        driverId: driverId ?? this.driverId,
        tripId: tripId ?? this.tripId,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'driverId': driverId,
        'tripId': tripId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };

  factory Review.fromMap(Map<dynamic, dynamic> map) => Review(
        id: ModelMap.text(map, 'id'),
        userId: ModelMap.text(map, 'userId'),
        driverId: ModelMap.text(map, 'driverId'),
        tripId: ModelMap.text(map, 'tripId'),
        rating: ModelMap.decimal(map, 'rating'),
        comment: ModelMap.text(map, 'comment'),
        createdAt: ModelMap.date(map, 'createdAt'),
      );
}