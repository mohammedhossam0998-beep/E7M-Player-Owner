import '../entities/ai_request_entity.dart';
import '../entities/ai_response_entity.dart';

abstract interface class AIRepository {
  Future<AIResponseEntity> sendMessage(
      AIRequestEntity request,
      );

  Stream<String> streamMessage(
      AIRequestEntity request,
      );
}