/// ===============================================================
/// AI Endpoints
/// ===============================================================

abstract final class AIEndpoints {
  const AIEndpoints._();

  static const String responses =
      '/v1/responses';

  static const String embeddings =
      '/v1/embeddings';

  static const String moderation =
      '/v1/moderations';
}