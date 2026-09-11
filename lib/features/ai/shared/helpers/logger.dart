import 'dart:developer';

final class Logger {
  const Logger._();

  static void info(
      String message,
      ) {
    log(
      message,
      name: 'E7M AI',
    );
  }

  static void warning(
      String message,
      ) {
    log(
      message,
      name: 'E7M AI Warning',
    );
  }

  static void error(
      Object error, {
        StackTrace? stackTrace,
      }) {
    log(
      error.toString(),
      name: 'E7M AI Error',
      stackTrace: stackTrace,
    );
  }
}