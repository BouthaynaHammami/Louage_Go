import 'package:flutter/material.dart';

class TripSearchCriteria {
  final String from;
  final String to;
  final DateTime date;
  final TimeOfDay time;
  final String? fromStationId;
  final String? toStationId;

  const TripSearchCriteria({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    this.fromStationId,
    this.toStationId,
  });
}
