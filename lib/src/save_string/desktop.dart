import 'dart:io';

import 'package:file_picker/file_picker.dart';

void save({
  required String content,
  required String filename,
}) {
  FilePicker.platform
      .saveFile(
    dialogTitle: 'Save text',
    fileName: filename,
  )
      .then((String? outputFile) {
    if (outputFile == null) {
      // user canceled the picker
      return;
    }

    final selectedFile = File(outputFile);
    if (selectedFile.existsSync()) {
      // do nothing if the file already exists
      // TODO: display an error message in this case
      return;
    }

    selectedFile.writeAsStringSync(content);
  });
}
