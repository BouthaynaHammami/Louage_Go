import 'model_map.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  const AppNotification({
    this.id = '',
    this.userId = '',
    this.title = '',
    this.message = '',
    this.type = '',
    this.isRead = false,
    this.createdAt = '',
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? createdAt,
  }) =>
      AppNotification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        message: message ?? this.message,
        type: type ?? this.type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt,
      };

  factory AppNotification.fromMap(Map<dynamic, dynamic> map) =>
      AppNotification(
        id: ModelMap.text(map, 'id'),
        userId: ModelMap.text(map, 'userId'),
        title: ModelMap.text(map, 'title'),
        message: ModelMap.text(map, 'message'),
        type: ModelMap.text(map, 'type'),
        isRead: ModelMap.boolean(map, 'isRead'),
        createdAt: ModelMap.date(map, 'createdAt'),
      );
}