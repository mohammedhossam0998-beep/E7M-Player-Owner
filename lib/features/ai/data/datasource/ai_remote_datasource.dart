import '../models/ai_request_model.dart';
import '../models/ai_response_model.dart';
import '../services/ai_service.dart';

class AIRemoteDataSource {
  const AIRemoteDataSource(
      this._service,
      );

  final AIService _service;

  Future<AIResponseModel> sendMessage(
      AIRequestModel request,
      ) {
    return _service.sendMessage(
      request,
    );
  }

  Stream<String> streamMessage(
      AIRequestModel request,
      ) {
    return _service.streamMessage(
      request,
    );
  }
}