import '../../../models/driver_document.dart';

abstract interface class DocumentRepository {
  /// Reactive stream of all documents for [driverId].
  Stream<List<DriverDocument>> watchDocuments(String driverId);

  /// Upload (or replace) a document: copies [sourceImagePath] to the app
  /// documents directory and upserts the record in Hive.
  Future<DriverDocument> saveDocument({
    required String driverId,
    required DocumentType type,
    required String sourceImagePath,
  });

  /// Upload all documents and automatically approve the driver account.
  /// No admin action is required — validation is immediate.
  Future<void> submitAll(String driverId);

  // ── Admin / debug helpers (used only in kDebugMode) ───────────────────────

  /// Simulate admin decision: approve all docs and set validationStatus to
  /// 'approved'.
  Future<void> debugApproveAll(String driverId);

  /// Simulate admin refusing [documentId] with [reason].
  Future<void> debugRejectDocument({
    required String driverId,
    required String documentId,
    required String reason,
  });
}
