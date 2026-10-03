import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../data/hive_booking_repository.dart';
import '../../domain/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => HiveBookingRepository(
    notifications: ref.read(notificationRepositoryProvider),
  ),
);

final userBookingsProvider = StreamProvider.autoDispose((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield const [];
    return;
  }
  yield* ref.watch(bookingRepositoryProvider).watchForUser(user.id);
});

final bookingControllerProvider =
    AsyncNotifierProvider<BookingController, void>(BookingController.new);

class BookingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> cancel(String bookingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw StateError('Sign-in required');
      await ref
          .read(bookingRepositoryProvider)
          .cancel(bookingId: bookingId, userId: user.id);
    });
  }
}
