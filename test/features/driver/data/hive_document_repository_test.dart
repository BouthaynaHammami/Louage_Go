import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/driver/data/hive_document_repository.dart';
import 'package:louage_go/models/driver_document.dart';
import 'package:louage_go/models/driver_profile.dart';

void main() {
  late Directory tempDirectory;
  late Box<Map> documentsBox;
  late Box<Map> driversBox;
  late HiveDocumentRepository repository;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'louagego_documents_test',
    );
    Hive.init(tempDirectory.path);
    documentsBox = await Hive.openBox<Map>('documents');
    driversBox = await Hive.openBox<Map>('drivers');
    repository = HiveDocumentRepository(
      documentsBox: documentsBox,
      driversBox: driversBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('submitting documents validates them and approves the driver', () async {
    await driversBox.put(
      'driver-1',
      const DriverProfile(userId: 'driver-1').toMap(),
    );
    await documentsBox.put(
      'uploaded-doc',
      const DriverDocument(
        id: 'uploaded-doc',
        driverId: 'driver-1',
        type: 'nationalId',
        status: 'sent',
      ).toMap(),
    );
    await documentsBox.put(
      'pending-doc',
      const DriverDocument(
        id: 'pending-doc',
        driverId: 'driver-1',
        type: 'driverLicense',
        status: 'toSend',
      ).toMap(),
    );
    await documentsBox.put(
      'other-driver-doc',
      const DriverDocument(
        id: 'other-driver-doc',
        driverId: 'driver-2',
        type: 'nationalId',
        status: 'sent',
      ).toMap(),
    );

    await repository.submitAll('driver-1');

    expect(
      DriverDocument.fromMap(documentsBox.get('uploaded-doc')!).status,
      DocumentStatus.validated.name,
    );
    expect(
      DriverDocument.fromMap(documentsBox.get('pending-doc')!).status,
      DocumentStatus.validated.name,
    );
    expect(
      DriverDocument.fromMap(documentsBox.get('other-driver-doc')!).status,
      DocumentStatus.sent.name,
    );
    expect(
      DriverProfile.fromMap(driversBox.get('driver-1')!).validationStatus,
      'approved',
    );
  });
}
