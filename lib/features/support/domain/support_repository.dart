import '../../../models/report.dart';

abstract interface class SupportRepository {
  Stream<List<Report>> watchRequests(String authorId);

  Future<Report> submitRequest({
    required String authorId,
    required String category,
    required String message,
    String tripId = '',
  });
}
