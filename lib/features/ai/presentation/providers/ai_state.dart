import '../../domain/entities/ai_message_entity.dart';

final class AIState {
  const AIState({
    this.isLoading = false,
    this.isStreaming = false,
    this.messages = const [],
    this.error,
  });

  final bool isLoading;
  final bool isStreaming;
  final List<AIMessageEntity> messages;
  final String? error;

  AIState copyWith({
    bool? isLoading,
    bool? isStreaming,
    List<AIMessageEntity>? messages,
    String? error,
  }) {
    return AIState(
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}