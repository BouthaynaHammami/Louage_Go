import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/hive_service.dart';
import '../../../models/driver_document.dart';
import '../../../models/driver_profile.dart';
import '../domain/document_repository.dart';

class HiveDocumentRepository implements DocumentRepository {
  HiveDocumentRepository({
    Box<Map>? documentsBox,
    Box<Map>? driversBox,
  })  : _documents = documentsBox ?? HiveService.documents,
        _drivers = driversBox ?? HiveService.drivers;

  final Box<Map> _documents;
  final Box<Map> _drivers;
  static const _uuid = Uuid();

  // ── Watch ──────────────────────────────────────────────────────────────────

  @override
  Stream<List<DriverDocument>> watchDocuments(String driverId) =>
      Stream<List<DriverDocument>>.multi((controller) {
        void reload() {
          try {
            controller.add(_docsFor(driverId));
          } catch (error, stackTrace) {
            controller.addError(error, stackTrace);
          }
        }

        final subscription = _documents.watch().listen((_) => reload());
        controller.onCancel = subscription.cancel;
        reload();
      });

  // ── Save (upload) ──────────────────────────────────────────────────────────

  @override
  Future<DriverDocument> saveDocument({
    required String driverId,
    required DocumentType type,
    required String sourceImagePath,
  }) async {
    // Copy image to app documents directory for persistence
    final destPath = await _copyImage(sourceImagePath, driverId, type.name);

    // Find existing record for this driver + type, or create new
    final existing = _docsFor(driverId)
        .where((d) => d.type == type.name)
        .firstOrNull;

    // Delete old file if replacing
    if (existing != null &&
        existing.imagePath.isNotEmpty &&
        existing.imagePath != destPath) {
      try {
        await File(existing.imagePath).delete();
      } catch (_) {
        // Best-effort cleanup — non-fatal
      }
    }

    final doc = DriverDocument(
      id: existing?.id ?? 'doc_${_uuid.v4()}',
      driverId: driverId,
      type: type.name,
      imagePath: destPath,
      status: DocumentStatus.sent.name,
      sentAt: DateTime.now().toIso8601String(),
    );

    await _documents.put(doc.id, doc.toMap());
    return doc;
  }

  // ── Submit all  (auto-approve — no admin required) ────────────────────────

  @override
  Future<void> submitAll(String driverId) async {
    // 1. Mark each toSend doc as sent
    for (final doc in _docsFor(driverId)) {
      if (doc.status == DocumentStatus.toSend.name) {
        await _documents.put(
          doc.id,
          doc
              .copyWith(
                status: DocumentStatus.sent.name,
                sentAt: DateTime.now().toIso8601String(),
              )
              .toMap(),
        );
      }
    }

    // 2. Auto-validate all sent docs and approve the driver immediately
    for (final doc in _docsFor(driverId)) {
      if (doc.status == DocumentStatus.sent.name) {
        await _documents.put(
          doc.id,
          doc.copyWith(status: DocumentStatus.validated.name).toMap(),
        );
      }
    }
    await _setValidationStatus(driverId, 'approved');
  }

  // ── Debug helpers ──────────────────────────────────────────────────────────

  @override
  Future<void> debugApproveAll(String driverId) async {
    for (final doc in _docsFor(driverId)) {
      await _documents.put(
        doc.id,
        doc.copyWith(status: DocumentStatus.validated.name).toMap(),
      );
    }
    await _setValidationStatus(driverId, 'approved');
  }

  @override
  Future<void> debugRejectDocument({
    required String driverId,
    required String documentId,
    required String reason,
  }) async {
    final map = _documents.get(documentId);
    if (map == null) return;
    final doc = DriverDocument.fromMap(map);
    await _documents.put(
      documentId,
      doc
          .copyWith(
            status: DocumentStatus.rejected.name,
            rejectionReason: reason,
          )
          .toMap(),
    );
    // Revert driver status so the pending screen is shown again
    await _setValidationStatus(driverId, 'pending');
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  List<DriverDocument> _docsFor(String driverId) => _documents.values
      .map(DriverDocument.fromMap)
      .where((d) => d.driverId == driverId)
      .toList();

  Future<void> _setValidationStatus(String driverId, String status) async {
    final map = _drivers.get(driverId);
    final profile = map == null
        ? DriverProfile(userId: driverId)
        : DriverProfile.fromMap(map);
    await _drivers.put(
      driverId,
      profile.copyWith(validationStatus: status).toMap(),
    );
  }

  /// Copies [source] to `<appDocsDir>/driver_docs/<driverId>/<type>_<uuid>.jpg`
  /// and returns the destination path.
  Future<String> _copyImage(
    String source,
    String driverId,
    String typeName,
  ) async {
    final appDir = await getApplicationDocumentsDirectory();
    final destDir =
        Directory('${appDir.path}/driver_docs/$driverId');
    await destDir.create(recursive: true);
    final ext = source.contains('.') ? source.split('.').last : 'jpg';
    final destPath = '${destDir.path}/${typeName}_${_uuid.v4()}.$ext';
    await File(source).copy(destPath);
    return destPath;
  }
}
