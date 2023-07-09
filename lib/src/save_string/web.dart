import 'dart:convert';
import 'dart:html' as html;

void save({
  required String content,
  required String filename,
}) {
  // copied from https://stackoverflow.com/a/60237118

  // prepare
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = filename;
  html.document.body!.children.add(anchor);

  // download
  anchor.click();

  // cleanup
  html.document.body!.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
