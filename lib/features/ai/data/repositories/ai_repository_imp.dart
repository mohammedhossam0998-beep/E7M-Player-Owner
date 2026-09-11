import '../../domain/entities/ai_request_entity.dart';
import '../../domain/entities/ai_response_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasource/ai_local_datasource.dart';
import '../datasource/ai_remote_datasource.dart';
import '../models/ai_request_model.dart';

final class AIRepositoryImpl implements AIRepository {
  const AIRepositoryImpl({
    required AIRemoteDataSource remoteDataSource,
    required AILocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AIRemoteDataSource _remoteDataSource;
  final AILocalDataSource _localDataSource;

  @override
  Future<AIResponseEntity> sendMessage(
      AIRequestEntity request,
      ) async {
    final response = await _remoteDataSource.sendMessage(
      AIRequestModel(
        message: request.message,
        userId: request.userId,
        languageCode: request.languageCode,
        conversationId: request.conversationId,
        context: request.context,
      ),
    );

    return AIResponseEntity(
      message: response.message,
      createdAt: response.createdAt,
      conversationId: response.conversationId,
      metadata: response.metadata,
    );
  }

  @override
  Stream<String> streamMessage(
      AIRequestEntity request,
      ) {
    return _remoteDataSource.streamMessage(
      AIRequestModel(
        message: request.message,
        userId: request.userId,
        languageCode: request.languageCode,
        conversationId: request.conversationId,
        context: request.context,
      ),
    );
  }
}