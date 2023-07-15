import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

import 'data_structures.dart';

class LinkedListWordConverter extends JsonConverter<LinkedList<Word>, List> {
  const LinkedListWordConverter();

  @override
  LinkedList<Word> fromJson(List json) {
    final linkedList = LinkedList<Word>();
    final words = json.map(
        (encodedWord) => Word.fromJson(encodedWord as Map<String, dynamic>));
    linkedList.addAll(words);
    return linkedList;
  }

  @override
  List toJson(LinkedList<Word> object) =>
      object.map((Word word) => word.toJson()).toList();
}
