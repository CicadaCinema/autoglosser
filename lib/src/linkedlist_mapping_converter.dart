import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';

import 'data_structures.dart';

class LinkedListMappingConverter
    extends JsonConverter<LinkedList<Mapping>, List<Map<String, dynamic>>> {
  const LinkedListMappingConverter();

  @override
  LinkedList<Mapping> fromJson(List<Map<String, dynamic>> json) {
    final linkedList = LinkedList<Mapping>();
    final mappings = json.map((Map<String, dynamic> encodedMapping) =>
        Mapping.fromJson(encodedMapping));
    linkedList.addAll(mappings);
    return linkedList;
  }

  @override
  List<Map<String, dynamic>> toJson(LinkedList<Mapping> object) =>
      object.map((Mapping mapping) => mapping.toJson()).toList();
}
