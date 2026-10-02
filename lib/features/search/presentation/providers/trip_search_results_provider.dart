import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_search_repository.dart';
import '../../domain/entities/louage_detail_data.dart';
import '../../domain/entities/passenger_home_data.dart';
import '../../domain/entities/trip_search_result.dart';
import '../../domain/search_repository.dart';
import '../../domain/trip_search_criteria.dart';

export '../../domain/entities/louage_detail_data.dart';
export '../../domain/entities/passenger_home_data.dart';
export '../../domain/entities/search_route_shortcut.dart';
export '../../domain/entities/trip_search_result.dart';

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => HiveSearchRepository(),
);

final passengerHomeDataProvider =
    StreamProvider.family<PassengerHomeData, String?>(
      (ref, userId) =>
          ref.watch(searchRepositoryProvider).watchPassengerHomeData(userId),
    );

final tripSearchResultsProvider =
    StreamProvider.family<List<TripSearchResult>, TripSearchCriteria>(
      (ref, criteria) =>
          ref.watch(searchRepositoryProvider).watchTripResults(criteria),
    );

final louageDetailDataProvider =
    FutureProvider.family<LouageDetailData?, String>(
      (ref, tripId) =>
          ref.watch(searchRepositoryProvider).getLouageDetail(tripId),
    );
