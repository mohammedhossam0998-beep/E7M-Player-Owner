import '../../shared/enums/ai_message_role.dart';

class AIMessageModel {
  const AIMessageModel({
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

  factory AIMessageModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AIMessageModel(
      id: json['id'] as String,
      conversationId:
      json['conversationId'] as String,
      role: AIMessageRole.values.firstWhere(
            (e) => e.name == json['role'],
      ),
      content: json['content'] as String,
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role.name,
      'content': content,
      'createdAt':
      createdAt.toIso8601String(),
    };
  }

  AIMessageModel copyWith({
    String? id,
    String? conversationId,
    AIMessageRole? role,
    String? content,
    DateTime? createdAt,
  }) {
    return AIMessageModel(
      id: id ?? this.id,
      conversationId:
      conversationId ??
          this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt:
      createdAt ?? this.createdAt,
    );
  }
}