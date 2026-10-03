import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/report.dart';
import '../domain/support_exception.dart';
import '../domain/support_repository.dart';

class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl({
    Box<Map>? reportsBox,
    DateTime Function()? now,
  }) : _reportsBox = reportsBox ?? HiveService.reports,
       _now = now ?? DateTime.now;

  static const _uuid = Uuid();

  final Box<Map> _reportsBox;
  final DateTime Function() _now;

  @override
  Stream<List<Report>> watchRequests(String authorId) async* {
    List<Report> read() {
      final reports = _reportsBox.values
          .map(Report.fromMap)
          .where(
            (report) =>
                report.type == 'support' && report.authorId == authorId,
          )
          .toList();
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    }

    yield read();
    await for (final _ in _reportsBox.watch()) {
      yield read();
    }
  }

  @override
  Future<Report> submitRequest({
    required String authorId,
    required String category,
    required String message,
    String tripId = '',
  }) async {
    final normalizedMessage = message.trim();
    if (authorId.trim().isEmpty) {
      throw const SupportException(SupportExceptionCode.signInRequired);
    }
    if (!const {
      'booking',
      'payment',
      'driver',
      'bug',
      'other',
    }.contains(category)) {
      throw const SupportException(SupportExceptionCode.invalidCategory);
    }
    if (normalizedMessage.length < 10 || normalizedMessage.length > 1000) {
      throw const SupportException(SupportExceptionCode.invalidMessage);
    }

    final openCount = _reportsBox.values
        .map(Report.fromMap)
        .where(
          (report) =>
              report.type == 'support' &&
              report.authorId == authorId &&
              const {'open', 'inProgress', 'in_progress'}.contains(
                report.status,
              ),
        )
        .length;
    if (openCount >= 3) {
      throw const SupportException(
        SupportExceptionCode.tooManyOpenRequests,
      );
    }

    final timestamp = _now().toIso8601String();
    final report = Report(
      id: _uuid.v4(),
      reporterId: authorId,
      targetId: tripId.trim(),
      targetType: 'support',
      reason: category,
      description: normalizedMessage,
      status: 'open',
      createdAt: timestamp,
      authorId: authorId,
      tripId: tripId.trim(),
      type: 'support',
      subject: category,
      category: category,
      updatedAt: timestamp,
    );
    await _reportsBox.put(report.id, report.toMap());
    return report;
  }
}
