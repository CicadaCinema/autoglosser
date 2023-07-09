import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

import 'data_structures.dart';

class LinkedListWordConverter
    extends JsonConverter<LinkedList<Word>, List<Map<String, dynamic>>> {
  const LinkedListWordConverter();

  @override
  LinkedList<Word> fromJson(List<Map<String, dynamic>> json) {
    final linkedList = LinkedList<Word>();
    final words = json
        .map((Map<String, dynamic> encodedWord) => Word.fromJson(encodedWord));
    linkedList.addAll(words);
    return linkedList;
  }

  @override
  List<Map<String, dynamic>> toJson(LinkedList<Word> object) =>
      object.map((Word word) => word.toJson()).toList();
}
