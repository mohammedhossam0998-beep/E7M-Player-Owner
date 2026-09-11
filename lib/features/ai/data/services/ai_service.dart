import '../models/ai_request_model.dart';
import '../models/ai_response_model.dart';

class AIService {
  const AIService();

  Future<AIResponseModel> sendMessage(
      AIRequestModel request,
      ) {
    throw UnsupportedError(
      'AI provider is not configured yet.',
    );
  }

  Stream<String> streamMessage(
      AIRequestModel request,
      ) {
    throw UnsupportedError(
      'Streaming provider is not configured yet.',
    );
  }
}