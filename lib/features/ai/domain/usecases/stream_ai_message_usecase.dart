import '../entities/ai_request_entity.dart';
import '../repositories/ai_repository.dart';

final class StreamAIMessageUseCase {
  const StreamAIMessageUseCase(
      this._repository,
      );

  final AIRepository _repository;

  Stream<String> call(
      AIRequestEntity request,
      ) {
    return _repository.streamMessage(
      request,
    );
  }
}