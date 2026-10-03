import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:louage_go/features/support/data/support_repository_impl.dart';
import 'package:louage_go/features/support/domain/support_exception.dart';
import 'package:louage_go/models/report.dart';

void main() {
  late Directory directory;
  late Box<Map> reports;
  late SupportRepositoryImpl repository;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('louagego_support_test');
    Hive.init(directory.path);
    reports = await Hive.openBox<Map>('reports');
    repository = SupportRepositoryImpl(
      reportsBox: reports,
      now: () => DateTime(2026, 10, 3, 12),
    );
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('only three unresolved support requests can be open per user', () async {
    final created = <Report>[];
    for (var index = 0; index < 3; index++) {
      created.add(
        await repository.submitRequest(
        authorId: 'user-a',
        category: 'booking',
        message: 'Please help with booking $index',
        ),
      );
    }
    await expectLater(
      repository.submitRequest(
        authorId: 'user-a',
        category: 'booking',
        message: 'Another booking support request',
      ),
      throwsA(
        isA<SupportException>().having(
          (error) => error.code,
          'code',
          SupportExceptionCode.tooManyOpenRequests,
        ),
      ),
    );
    await repository.submitRequest(
      authorId: 'user-b',
      category: 'booking',
      message: 'Separate user request',
    );
    await reports.put(
      created.first.id,
      created.first.copyWith(status: 'resolved').toMap(),
    );
    await repository.submitRequest(
      authorId: 'user-a',
      category: 'booking',
      message: 'A resolved request frees an open slot',
    );
  });

  test('requests are isolated by author and existing fields stay compatible', () async {
    final request = await repository.submitRequest(
      authorId: 'user-a',
      category: 'driver',
      tripId: 'trip-1',
      message: 'There is an issue with my driver trip',
    );
    await reports.put('old-report', {
      'id': 'old-report',
      'reporterId': 'user-a',
      'targetId': 'trip-old',
      'targetType': 'incident',
      'description': 'legacy report',
      'status': 'pending',
    });

    final fromA = await repository.watchRequests('user-a').first;
    final fromB = await repository.watchRequests('user-b').first;

    expect(fromA, [isA<Report>()]);
    expect(fromA.single.id, request.id);
    expect(fromA.single.authorId, 'user-a');
    expect(fromA.single.tripId, 'trip-1');
    expect(fromA.single.type, 'support');
    expect(fromB, isEmpty);
    final legacy = Report.fromMap(reports.get('old-report')!);
    expect(legacy.reporterId, 'user-a');
    expect(legacy.targetId, 'trip-old');
    expect(legacy.status, 'pending');
  });

  test('rejects invalid category and messages before writing', () async {
    await expectLater(
      repository.submitRequest(
        authorId: 'user-a',
        category: 'invalid',
        message: 'This is a valid length message',
      ),
      throwsA(isA<SupportException>()),
    );
    await expectLater(
      repository.submitRequest(
        authorId: 'user-a',
        category: 'bug',
        message: 'short',
      ),
      throwsA(isA<SupportException>()),
    );
    expect(reports, isEmpty);
  });
}
