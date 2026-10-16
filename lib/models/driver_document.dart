import 'model_map.dart';

/// Status lifecycle for a single uploaded document.
enum DocumentStatus {
  toSend,    // Not yet uploaded
  sent,      // Uploaded, awaiting admin review
  rejected,  // Admin rejected it (see [rejectionReason])
  validated, // Admin validated it
}

/// Type of required document for driver validation.
enum DocumentType {
  nationalId,       // Carte d'identité nationale
  driverLicense,    // Permis de conduire
  vehicleCard,      // Carte grise du louage
  insurance,        // Assurance
  transportLicense, // Licence de transport
  driverPhoto,      // Photo du chauffeur
  vehiclePhoto,     // Photo du louage
}

class DriverDocument {
  final String id;
  final String driverId;

  /// Discriminator — maps to [DocumentType.name]
  final String type;

  /// Absolute path of the image file saved on-device.
  /// Empty when status == [DocumentStatus.toSend].
  final String imagePath;

  /// Maps to [DocumentStatus.name]
  final String status;

  /// Non-empty only when [status] == 'rejected'.
  final String rejectionReason;

  /// ISO-8601 string of when the doc was last uploaded (empty if not yet sent).
  final String sentAt;

  const DriverDocument({
    this.id = '',
    this.driverId = '',
    this.type = '',
    this.imagePath = '',
    this.status = 'toSend',
    this.rejectionReason = '',
    this.sentAt = '',
  });

  DocumentStatus get documentStatus => DocumentStatus.values.firstWhere(
    (s) => s.name == status,
    orElse: () => DocumentStatus.toSend,
  );

  DocumentType? get documentType {
    try {
      return DocumentType.values.firstWhere((t) => t.name == type);
    } catch (_) {
      return null;
    }
  }

  DriverDocument copyWith({
    String? id,
    String? driverId,
    String? type,
    String? imagePath,
    String? status,
    String? rejectionReason,
    String? sentAt,
  }) =>
      DriverDocument(
        id: id ?? this.id,
        driverId: driverId ?? this.driverId,
        type: type ?? this.type,
        imagePath: imagePath ?? this.imagePath,
        status: status ?? this.status,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        sentAt: sentAt ?? this.sentAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'driverId': driverId,
        'type': type,
        'imagePath': imagePath,
        'status': status,
        'rejectionReason': rejectionReason,
        'sentAt': sentAt,
      };

  factory DriverDocument.fromMap(Map<dynamic, dynamic> map) => DriverDocument(
        id: ModelMap.text(map, 'id'),
        driverId: ModelMap.text(map, 'driverId'),
        type: ModelMap.text(map, 'type'),
        imagePath: ModelMap.text(map, 'imagePath'),
        status: ModelMap.text(map, 'status', 'toSend'),
        rejectionReason: ModelMap.text(map, 'rejectionReason'),
        sentAt: ModelMap.text(map, 'sentAt'),
      );
}
