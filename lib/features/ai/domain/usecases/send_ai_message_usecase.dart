import '../entities/ai_request_entity.dart';
import '../entities/ai_response_entity.dart';
import '../repositories/ai_repository.dart';

final class SendAIMessageUseCase {
  const SendAIMessageUseCase(
      this._repository,
      );

  final AIRepository _repository;

  Future<AIResponseEntity> call(
      AIRequestEntity request,
      ) {
    return _repository.sendMessage(
      request,
    );
  }
}