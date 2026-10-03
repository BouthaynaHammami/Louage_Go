import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/report.dart';
import 'data/support_repository_impl.dart';
import 'domain/support_repository.dart';

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepositoryImpl(),
);

final supportRequestsProvider =
    StreamProvider.autoDispose.family<List<Report>, String>(
      (ref, authorId) =>
          ref.watch(supportRepositoryProvider).watchRequests(authorId),
    );

final supportControllerProvider =
    AsyncNotifierProvider<SupportController, void>(SupportController.new);

class SupportController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Report> submit({
    required String authorId,
    required String category,
    required String message,
    String tripId = '',
  }) async {
    state = const AsyncLoading();
    try {
      final report = await ref.read(supportRepositoryProvider).submitRequest(
        authorId: authorId,
        category: category,
        message: message,
        tripId: tripId,
      );
      state = const AsyncData(null);
      return report;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
