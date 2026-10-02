import 'entities/louage_detail_data.dart';
import 'entities/passenger_home_data.dart';
import 'entities/trip_search_result.dart';
import 'trip_search_criteria.dart';

abstract interface class SearchRepository {
  Stream<PassengerHomeData> watchPassengerHomeData(String? userId);

  Future<void> rememberSearch(String from, String to);

  Stream<List<TripSearchResult>> watchTripResults(TripSearchCriteria criteria);

  List<TripSearchResult> findTrips(TripSearchCriteria criteria);

  Future<LouageDetailData?> getLouageDetail(String tripId);
}
