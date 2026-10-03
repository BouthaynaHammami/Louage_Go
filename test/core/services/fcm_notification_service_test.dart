import 'package:flutter_test/flutter_test.dart';
import 'package:louage_go/core/services/fcm_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Firebase initialization failure leaves the service in local mode',
    () async {
      final service = FcmNotificationService(
        initializeFirebase: () async {
          throw UnsupportedError('Firebase options are Android-only');
        },
        initializeLocalNotifications: () async {},
        initializeAndroidChannel: (channelName) async {},
      );

      await expectLater(
        service.init(
          persistRemoteNotification: ({
            required title,
            required message,
            required type,
            required route,
            required data,
            required messageId,
          }) async {},
          channelName: 'Test notifications',
        ),
        completes,
      );
      expect(service.firebaseAvailable, isFalse);

      await service.dispose();
    },
  );
}
