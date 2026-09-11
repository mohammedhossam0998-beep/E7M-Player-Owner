import 'ai_constants.dart';

/// ===============================================================
/// AI Configuration
/// ===============================================================

final class AIConfig {
  const AIConfig._();

  static const String moduleName =
      'E7M AI';

  static const String version =
      '1.0.0';

  static const bool enableLogs = true;

  static const bool enableStreaming =
      AIConstants.enableStreaming;

  static const bool enableMemory =
      AIConstants.enableMemory;

  static const bool enableSafety =
      AIConstants.enableSafety;
}