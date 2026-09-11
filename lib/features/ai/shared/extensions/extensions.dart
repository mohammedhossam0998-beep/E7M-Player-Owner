extension StringExtensions on String {
  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => trim().isNotEmpty;

  String get capitalize {
    if (isEmpty) return this;

    return this[0].toUpperCase() + substring(1);
  }

  String get normalized {
    return trim()
        .replaceAll('\r', '')
        .replaceAll('\n\n', '\n');
  }
}

extension IterableExtensions<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;

    return first;
  }

  T? get lastOrNull {
    if (isEmpty) return null;

    return last;
  }
}