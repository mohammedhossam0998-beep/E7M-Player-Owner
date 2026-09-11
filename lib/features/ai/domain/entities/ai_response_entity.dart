class AIResponseEntity {
  const AIResponseEntity({
    required this.message,
    required this.createdAt,
    this.conversationId,
    this.metadata = const {},
  });

  final String message;
  final DateTime createdAt;
  final String? conversationId;
  final Map<String, dynamic> metadata;
}