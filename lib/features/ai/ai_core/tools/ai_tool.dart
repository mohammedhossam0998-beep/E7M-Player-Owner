abstract interface class AITool {
  const AITool();

  /// Unique tool identifier.
  String get id;

  /// Display name.
  String get name;

  /// Tool description.
  String get description;

  /// Execute tool.
  Future<AIToolResult> execute(
      Map<String, dynamic> arguments,
      );

  /// Check whether the tool can execute.
  bool canExecute(
      Map<String, dynamic> arguments,
      );
}

final class AIToolResult {
  const AIToolResult({
    required this.success,
    required this.message,
    this.data = const {},
  });

  final bool success;

  final String message;

  final Map<String, dynamic> data;
}