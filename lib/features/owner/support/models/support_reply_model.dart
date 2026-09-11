class SupportReplyModel {
  final int id;
  final int ticketId;
  final int adminId;
  final String message;
  final DateTime createdAt;

  const SupportReplyModel({
    required this.id,
    required this.ticketId,
    required this.adminId,
    required this.message,
    required this.createdAt,
  });

  factory SupportReplyModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return SupportReplyModel(
      id: int.parse(json['id'].toString()),
      ticketId: int.parse(
        json['ticket_id'].toString(),
      ),
      adminId: int.parse(
        json['admin_id'].toString(),
      ),
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.parse(
        json['created_at'].toString(),
      ),
    );
  }
}