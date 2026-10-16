import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/hive_document_repository.dart';
import '../../domain/document_repository.dart';
import '../../../../models/driver_document.dart';

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => HiveDocumentRepository(),
);

/// Stream of all documents for the given driverId.
final driverDocumentsProvider =
    StreamProvider.family<List<DriverDocument>, String>(
      (ref, driverId) =>
          ref.watch(documentRepositoryProvider).watchDocuments(driverId),
    );

/// Whether all required document types have been uploaded (status != toSend).
final allDocumentsUploadedProvider =
    Provider.family<bool, List<DriverDocument>>((ref, docs) {
  final required = DocumentType.values;
  return required.every(
    (type) => docs.any(
      (d) => d.type == type.name && d.status != DocumentStatus.toSend.name,
    ),
  );
});
