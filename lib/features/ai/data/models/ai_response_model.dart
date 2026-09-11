class AIResponseModel {
  const AIResponseModel({
    required this.message,
    required this.createdAt,
    this.conversationId,
    this.metadata = const {},
  });

  final String message;

  final DateTime createdAt;

  final String? conversationId;

  final Map<String, dynamic> metadata;

  factory AIResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AIResponseModel(
      message: json['message'] as String,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      conversationId:
      json['conversationId']
      as String?,
      metadata:
      Map<String, dynamic>.from(
        json['metadata'] ??
            const {},
      ),
    );
  }
}