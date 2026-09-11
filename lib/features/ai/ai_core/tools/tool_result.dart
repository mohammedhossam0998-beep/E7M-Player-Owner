class ToolResult {
  const ToolResult({
    required this.success,
    required this.message,
    this.payload = const {},
  });

  final bool success;

  final String message;

  final Map<String, dynamic> payload;

  ToolResult copyWith({
    bool? success,
    String? message,
    Map<String, dynamic>? payload,
  }) {
    return ToolResult(
      success: success ?? this.success,
      message: message ?? this.message,
      payload: payload ?? this.payload,
    );
  }
}