class SupportTicketModel {
  final int id;
  final int userId;
  final String subject;
  final String message;
  final String status;
  final String priority;
  final int? assignedAdminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    required this.assignedAdminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicketModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return SupportTicketModel(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      priority: json['priority']?.toString() ?? 'medium',
      assignedAdminId:
      json['assigned_admin_id'] == null
          ? null
          : int.parse(
        json['assigned_admin_id'].toString(),
      ),
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'].toString(),
      ),
    );
  }
}