import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

import 'data_structures.dart';

class LinkedListMappingConverter
    extends JsonConverter<LinkedList<Mapping>, List> {
  const LinkedListMappingConverter();

  @override
  LinkedList<Mapping> fromJson(List json) {
    final linkedList = LinkedList<Mapping>();
    final mappings = json.map((encodedMapping) =>
        Mapping.fromJson(encodedMapping as Map<String, dynamic>));
    linkedList.addAll(mappings);
    return linkedList;
  }

  @override
  List toJson(LinkedList<Mapping> object) =>
      object.map((Mapping mapping) => mapping.toJson()).toList();
}
