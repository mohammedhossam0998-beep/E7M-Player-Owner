import '../../domain/entities/ai_request_entity.dart';
import '../../domain/usecases/send_ai_message_usecase.dart';
import '../../domain/usecases/stream_ai_message_usecase.dart';

final class AIChatController {
  AIChatController({
    required SendAIMessageUseCase sendAIMessageUseCase,
    required StreamAIMessageUseCase streamAIMessageUseCase,
  })  : _sendAIMessageUseCase = sendAIMessageUseCase,
        _streamAIMessageUseCase = streamAIMessageUseCase;

  final SendAIMessageUseCase _sendAIMessageUseCase;
  final StreamAIMessageUseCase _streamAIMessageUseCase;

  Future<void> sendMessage({
    required String message,
    required String userId,
    required String languageCode,
    required String conversationId,
  }) async {
    await _sendAIMessageUseCase(
      AIRequestEntity(
        message: message,
        userId: userId,
        languageCode: languageCode,
        conversationId: conversationId,
      ),
    );
  }

  Stream<String> streamMessage({
    required String message,
    required String userId,
    required String languageCode,
    required String conversationId,
  }) {
    return _streamAIMessageUseCase(
      AIRequestEntity(
        message: message,
        userId: userId,
        languageCode: languageCode,
        conversationId: conversationId,
      ),
    );
  }
}
