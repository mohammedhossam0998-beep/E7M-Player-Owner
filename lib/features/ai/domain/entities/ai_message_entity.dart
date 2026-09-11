class AIMessageEntity {
  const AIMessageEntity({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;

  final String conversationId;

  final AIMessageRole role;

  final String content;

  final DateTime createdAt;

  AIMessageEntity copyWith({
    String? id,
    String? conversationId,
    AIMessageRole? role,
    String? content,
    DateTime? createdAt,
  }) {
    return AIMessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum AIMessageRole {
  user,
  assistant,
  system,
}
