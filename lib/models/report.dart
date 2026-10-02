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

  const Report({
    this.id = '',
    this.reporterId = '',
    this.targetId = '',
    this.targetType = '',
    this.reason = '',
    this.description = '',
    this.status = 'pending',
    this.createdAt = '',
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
      );
}