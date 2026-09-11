abstract final class AICoreConstants {
  const AICoreConstants._();

  static const String assistantName = 'E7M AI';

  static const String version = '1.0.0';

  static const int maxHistoryMessages = 30;

  static const int maxContextMessages = 10;

  static const int maxRetryCount = 3;

  static const Duration requestTimeout =
  Duration(seconds: 60);

  static const bool enableStreaming = true;

  static const bool enableMemory = true;

  static const bool enableLogging = true;
}