import 'model_map.dart';

class Report {
  final String id;
  final String reporterId;
  final String targetId;
  final String targetType;
  final String reason;
  final String description;
  final String status;
  final String createdAt;
  final String authorId;
  final String tripId;
  final String type;
  final String subject;
  final String category;
  final String updatedAt;
  final String adminReply;

  const Report({
    this.id = '',
    this.reporterId = '',
    this.targetId = '',
    this.targetType = '',
    this.reason = '',
    this.description = '',
    this.status = 'pending',
    this.createdAt = '',
    this.authorId = '',
    this.tripId = '',
    this.type = '',
    this.subject = '',
    this.category = '',
    this.updatedAt = '',
    this.adminReply = '',
  });

  Report copyWith({
    String? id,
    String? reporterId,
    String? targetId,
    String? targetType,
    String? reason,
    String? description,
    String? status,
    String? createdAt,
    String? authorId,
    String? tripId,
    String? type,
    String? subject,
    String? category,
    String? updatedAt,
    String? adminReply,
  }) =>
      Report(
        id: id ?? this.id,
        reporterId: reporterId ?? this.reporterId,
        targetId: targetId ?? this.targetId,
        targetType: targetType ?? this.targetType,
        reason: reason ?? this.reason,
        description: description ?? this.description,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        authorId: authorId ?? this.authorId,
        tripId: tripId ?? this.tripId,
        type: type ?? this.type,
        subject: subject ?? this.subject,
        category: category ?? this.category,
        updatedAt: updatedAt ?? this.updatedAt,
        adminReply: adminReply ?? this.adminReply,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'reporterId': reporterId,
        'targetId': targetId,
        'targetType': targetType,
        'reason': reason,
        'description': description,
        'status': status,
        'createdAt': createdAt,
        'authorId': authorId.isEmpty ? reporterId : authorId,
        'tripId': tripId.isEmpty ? targetId : tripId,
        'type': type.isEmpty ? targetType : type,
        'subject': subject,
        'category': category,
        'updatedAt': updatedAt,
        'adminReply': adminReply,
      };

  factory Report.fromMap(Map<dynamic, dynamic> map) => Report(
        id: ModelMap.text(map, 'id'),
        reporterId: ModelMap.text(map, 'reporterId'),
        targetId: ModelMap.text(map, 'targetId'),
        targetType: ModelMap.text(map, 'targetType'),
        reason: ModelMap.text(map, 'reason'),
        description: ModelMap.text(map, 'description'),
        status: ModelMap.text(map, 'status', 'pending'),
        createdAt: ModelMap.date(map, 'createdAt'),
        authorId: ModelMap.text(
          map,
          'authorId',
          ModelMap.text(map, 'reporterId'),
        ),
        tripId: ModelMap.text(map, 'tripId', ModelMap.text(map, 'targetId')),
        type: ModelMap.text(map, 'type', ModelMap.text(map, 'targetType')),
        subject: ModelMap.text(map, 'subject'),
        category: ModelMap.text(map, 'category'),
        updatedAt: ModelMap.date(map, 'updatedAt'),
        adminReply: ModelMap.text(map, 'adminReply'),
      );
}