class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return NotificationModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ),
    );
  }
}