/// ===============================================================
/// E7M AI
/// AI Constants
/// Production Ready
/// ===============================================================

abstract final class AIConstants {
  const AIConstants._();

  // Chat

  static const int maxConversationMessages = 30;

  static const int maxPromptLength = 12000;

  static const int maxResponseLength = 16000;

  // Streaming

  static const bool enableStreaming = true;

  // Memory

  static const bool enableMemory = true;

  static const int maxMemoryMessages = 100;

  // Safety

  static const bool enableSafety = true;

  // Timeout

  static const Duration requestTimeout =
  Duration(seconds: 60);

  // Retry

  static const int maxRetryCount = 3;

  // Localization

  static const String defaultLanguage = 'en';

  static const List<String> supportedLanguages = [
    'en',
    'ar',
  ];
}