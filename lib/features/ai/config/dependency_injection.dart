import '../data/datasource/ai_local_datasource.dart';
import '../data/datasource/ai_remote_datasource.dart';
import '../data/repositories/ai_repository_imp.dart';
import '../data/services/ai_service.dart';
import '../domain/repositories/ai_repository.dart';

/// ===============================================================
/// AI Dependency Injection
/// ===============================================================

final class AIDependencyInjection {
  const AIDependencyInjection._();

  static late final AIService aiService;

  static late final AILocalDataSource localDataSource;

  static late final AIRemoteDataSource remoteDataSource;

  static late final AIRepository repository;

  static Future<void> initialize() async {
    aiService = AIService();

    localDataSource = AILocalDataSource();

    remoteDataSource = AIRemoteDataSource(aiService);

    repository = AIRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  }
}