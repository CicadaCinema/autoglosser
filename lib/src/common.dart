extension StringExt on String {
  /// Split the first character away from the rest of the string.
  (String, String) splitOnFirstChar() =>
      (substring(0, 1), substring(1, length));

  /// Split on the first space character.
  (String, String) splitOnSpace() {
    final sepIndex = indexOf(' ');
    return (substring(0, sepIndex), substring(sepIndex + 1, length));
  }
}
