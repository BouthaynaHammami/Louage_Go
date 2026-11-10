import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

enum RouteExceptionType {
  network,
  timeout,
  noRoute,
  invalidResponse,
  locationDenied,
  locationDeniedForever,
  locationServiceDisabled,
  locationUnavailable,
}

class RouteException implements Exception {
  const RouteException(this.type, [this.cause]);

  final RouteExceptionType type;
  final Object? cause;

  @override
  String toString() =>
      'RouteException($type${cause == null ? '' : ': $cause'})';
}

class RouteInfo {
  const RouteInfo({
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final double distanceMeters;
  final double durationSeconds;

  int get roundedDurationMinutes => (durationSeconds / 60).round();
  int get durationHours => roundedDurationMinutes ~/ 60;
  int get remainingDurationMinutes => roundedDurationMinutes % 60;

  String get formattedDistance {
    if (distanceMeters < 1000) return '${distanceMeters.round()} m';
    return '${NumberFormat('0.0').format(distanceMeters / 1000)} km';
  }

  String formattedDistanceFor(Locale locale) {
    if (distanceMeters < 1000) return formattedDistance;
    final kilometers = NumberFormat(
      '0.0',
      locale.toString(),
    ).format(distanceMeters / 1000);
    return '$kilometers km';
  }

  String get formattedDuration {
    final minutes = roundedDurationMinutes;
    if (minutes < 60) return '$minutes min';
    return '${minutes ~/ 60} h ${(minutes % 60).toString().padLeft(2, '0')}';
  }
}

abstract interface class RouteService {
  Future<RouteInfo> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  });
}

class OsrmRouteService implements RouteService {
  OsrmRouteService({
    http.Client? client,
    this._timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final Duration _timeout;

  @override
  Future<RouteInfo> getRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/$fromLng,$fromLat;$toLng,$toLat',
      {'overview': 'false'},
    );

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(_timeout);
    } on TimeoutException catch (error) {
      throw RouteException(RouteExceptionType.timeout, error);
    } on http.ClientException catch (error) {
      throw RouteException(RouteExceptionType.network, error);
    }

    if (response.statusCode != 200) {
      throw RouteException(
        RouteExceptionType.network,
        'OSRM returned HTTP ${response.statusCode}',
      );
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      throw RouteException(RouteExceptionType.invalidResponse, error);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const RouteException(RouteExceptionType.invalidResponse);
    }

    final code = decoded['code'];
    if (code != 'Ok') {
      if (code == 'NoRoute' || code == 'NoSegment') {
        throw const RouteException(RouteExceptionType.noRoute);
      }
      throw const RouteException(RouteExceptionType.invalidResponse);
    }

    final routes = decoded['routes'];
    if (routes is! List || routes.isEmpty) {
      throw const RouteException(RouteExceptionType.noRoute);
    }
    final route = routes.first;
    if (route is! Map<String, dynamic>) {
      throw const RouteException(RouteExceptionType.invalidResponse);
    }
    final distance = route['distance'];
    final duration = route['duration'];
    if (distance is! num ||
        duration is! num ||
        !distance.isFinite ||
        !duration.isFinite ||
        distance < 0 ||
        duration < 0) {
      throw const RouteException(RouteExceptionType.invalidResponse);
    }

    return RouteInfo(
      distanceMeters: distance.toDouble(),
      durationSeconds: duration.toDouble(),
    );
  }
}
