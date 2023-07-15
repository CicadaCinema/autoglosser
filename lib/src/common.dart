import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

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

String filePickerResultToString(FilePickerResult? result) {
  if (result == null || result.files.isEmpty) {
    // User cancelled the selection.
    // TODO: implement error handling.
    throw UnimplementedError();
  }
  // We must hadle the web platform differently from other platforms.
  // https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ#q-how-do-i-access-the-path-on-web
  if (kIsWeb) {
    return utf8.decode(result.files.single.bytes!);
  } else {
    return File(result.files.single.path!).readAsStringSync();
  }
}
