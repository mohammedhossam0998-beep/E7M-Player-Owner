class AIRequestEntity {
  const AIRequestEntity({
    required this.message,
    required this.userId,
    required this.languageCode,
    this.conversationId,
    this.context = const {},
  });

  final String message;
  final String userId;
  final String languageCode;
  final String? conversationId;
  final Map<String, dynamic> context;
}
