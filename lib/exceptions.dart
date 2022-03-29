class UncaughtException implements Exception {
  UncaughtException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ManuallyCaughtException implements Exception {
  ManuallyCaughtException(this.message);

  final String message;

  @override
  String toString() => message;
}
