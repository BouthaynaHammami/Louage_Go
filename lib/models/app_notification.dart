import 'model_map.dart';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final String route;
  final Map<String, dynamic> data;
  final String messageId;

  const AppNotification({
    this.id = '',
    this.userId = '',
    this.title = '',
    this.message = '',
    this.type = '',
    this.isRead = false,
    this.createdAt = '',
    this.route = '',
    this.data = const {},
    this.messageId = '',
  });

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? createdAt,
    String? route,
    Map<String, dynamic>? data,
    String? messageId,
  }) => AppNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    message: message ?? this.message,
    type: type ?? this.type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
    route: route ?? this.route,
    data: data ?? this.data,
    messageId: messageId ?? this.messageId,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'message': message,
    'type': type,
    'isRead': isRead,
    'createdAt': createdAt,
    'route': route,
    'data': data,
    'messageId': messageId,
  };

  factory AppNotification.fromMap(Map<dynamic, dynamic> map) {
    final rawData = map['data'];
    return AppNotification(
      id: ModelMap.text(map, 'id'),
      userId: ModelMap.text(map, 'userId'),
      title: ModelMap.text(map, 'title'),
      message: ModelMap.text(map, 'message'),
      type: ModelMap.text(map, 'type'),
      isRead: ModelMap.boolean(map, 'isRead'),
      createdAt: ModelMap.date(map, 'createdAt'),
      route: ModelMap.text(map, 'route'),
      data: rawData is Map
          ? rawData.map((key, value) => MapEntry(key.toString(), value))
          : const {},
      messageId: ModelMap.text(map, 'messageId'),
    );
  }
}
