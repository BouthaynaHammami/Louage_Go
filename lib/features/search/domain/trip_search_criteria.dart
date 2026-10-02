import 'package:flutter/material.dart';

class TripSearchCriteria {
  final String from;
  final String to;
  final DateTime date;
  final TimeOfDay time;

  const TripSearchCriteria({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
  });
}
