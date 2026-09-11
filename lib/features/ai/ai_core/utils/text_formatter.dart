final class TextFormatter {
  const TextFormatter._();

  static String normalize(
      String value,
      ) {
    return value
        .replaceAll('\n\n', '\n')
        .replaceAll('\r', '')
        .trim();
  }

  static String capitalize(
      String value,
      ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }

  static bool isEmpty(
      String? value,
      ) {
    return value == null ||
        value.trim().isEmpty;
  }
}