import 'package:uuid/uuid.dart';

final class UuidGenerator {
  const UuidGenerator._();

  static const Uuid _uuid = Uuid();

  static String generate() {
    return _uuid.v4();
  }
}