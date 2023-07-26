import 'dart:collection';

import 'package:autoglosser/src/linkedlist_mapping_converter.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

export './global_providers/selected_word.dart';
export './global_providers/selected_chunk.dart';
export './global_providers/selected_mapping.dart';
export './global_providers/selected_language.dart';

import '../break_kind_converter.dart';
import '../linkedlist_word_converter.dart';

part 'data_structures.g.dart';

// TODO: get rid of this and use the enum below instead, like in the settings page
const breakKinds = [
  'no break',
  'line break',
  'chunk break',
  'page break',
];

// NOTE: be careful modifying this enum or adding elements to it! Check references.
enum BreakKinds {
  noBreak,
  lineBreak,
  chunkBreak,
  pageBreak,
}

/// An instance of one of: [NoBreak], [LineBreak], [ChunkBreak] or [PageBreak].
sealed class BreakKind {}

// TODO: Can these classes all extend one another? Will this be useful?
class NoBreak implements BreakKind {}

class LineBreak implements BreakKind {}

class ChunkBreak implements BreakKind {
  /// The translation of the chunk which is terminated by this chunk break.
  String chunkTranslation;

  ChunkBreak({this.chunkTranslation = 'Lorem.'});
}

class PageBreak extends ChunkBreak implements BreakKind {
  PageBreak({super.chunkTranslation});
}

@JsonSerializable()
final class Word extends LinkedListEntry<Word> {
  String source;
  String pronounciation = '-';
  String gloss = '-';

  @BreakKindConverter()
  BreakKind breakKind = NoBreak();

  Word({required this.source});

  Word._allFields({
    required this.source,
    required this.pronounciation,
    required this.gloss,
    required this.breakKind,
  });

  /// Returns [true] if and only if the [source], [pronounciation], [gloss] and
  /// (the type and any fields of) [breakKind] fields of [this] and [other]
  /// match.
  // TODO: possibly make this an extension method.
  bool equals(Word other) {
    final stringFieldsMatch = source == other.source &&
        pronounciation == other.pronounciation &&
        gloss == other.gloss;
    if (!stringFieldsMatch) {
      return false;
    }

    // We need these local variables for implicit type coercion.
    final thisBreakKind = breakKind;
    final otherBreakKind = other.breakKind;
    if (thisBreakKind is PageBreak) {
      return otherBreakKind is PageBreak &&
          thisBreakKind.chunkTranslation == otherBreakKind.chunkTranslation;
    } else if (thisBreakKind is ChunkBreak) {
      return otherBreakKind is ChunkBreak &&
          thisBreakKind.chunkTranslation == otherBreakKind.chunkTranslation;
    } else if (thisBreakKind is LineBreak) {
      return otherBreakKind is LineBreak;
    } else if (thisBreakKind is NoBreak) {
      return otherBreakKind is NoBreak;
    } else {
      throw StateError('The field breakKind has an invalid type.');
    }
  }

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  Map<String, dynamic> toJson() => _$WordToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  converters: [LinkedListWordConverter()],
)
class FullText {
  /// All the words comprising the source text.
  LinkedList<Word> allWords;

  FullText.fromString({
    required String source,
    required SourceLanguage sourceLanguage,
  }) : allWords = LinkedList() {
    // By default, the source text is delimited by newline characters into chunks.
    for (final String chunkString in source.split('\n')) {
      // All the words on this line (and so by default, this chunk).
      final List<String> wordsOnThisLineString = switch (sourceLanguage) {
        SourceLanguage.chinese =>
          chunkString.runes.map((rune) => String.fromCharCode(rune)).toList(),
        SourceLanguage.alphabetic => chunkString.split(' '),
      };
      final List<Word> wordsOnThisLine = wordsOnThisLineString
          .map((String wordString) => Word(source: wordString))
          .toList();
      // Mark the end of this line (and so by default, this chunk) with a chunk break.
      // FIXME: ensure .last does not throw an exception.
      wordsOnThisLine.last.breakKind = ChunkBreak();

      allWords.addAll(wordsOnThisLine);
    }
  }

  FullText._allFields({required this.allWords});

  factory FullText.fromJson(Map<String, dynamic> json) =>
      _$FullTextFromJson(json);

  Map<String, dynamic> toJson() => _$FullTextToJson(this);
}

@JsonSerializable()
final class Mapping extends LinkedListEntry<Mapping> {
  // TODO: remove thees three setters (make them private instead), instead force the user to go through the [FullMap] interface.
  String pronounciation;
  String source;
  List<String> translation;

  Mapping({
    required this.pronounciation,
    required this.source,
    required this.translation,
  });

  Mapping._allFields({
    required this.pronounciation,
    required this.source,
    required this.translation,
  });

  /// Returns [true] if and only if the [pronounciation], [source] and
  /// [translation] (compared element-wise) fields of [this] and [other] match.
  // TODO: possibly make this an extension method.
  bool equals(Mapping other) =>
      pronounciation == other.pronounciation &&
      source == other.source &&
      const ListEquality().equals(translation, other.translation);

  factory Mapping.fromJson(Map<String, dynamic> json) =>
      _$MappingFromJson(json);

  Map<String, dynamic> toJson() => _$MappingToJson(this);
}

@JsonSerializable(
  explicitToJson: true,
  converters: [LinkedListMappingConverter()],
)
class FullMap {
  // TODO: protect against accidentally modifying this map.
  // TODO: use a SplayTreeSet rather than a LinkedList for improved performance.
  // (see https://ece.uwaterloo.ca/~dwharder/aads/Abstract_data_types/Linear_ordering/Sorted_list/ )
  /// Maps from the name of a section to a linked list of mappings in that section,
  /// sorted by pronunciation.
  final Map<String, LinkedList<Mapping>> mappingSections;

  /// Maps from a source word to the list of mappings associated with that word, across all sections.
  final Map<String, List<Mapping>> _sourceToMappings;

  List<Mapping>? souceToMappings(String source) => _sourceToMappings[source];

  /// Adds a mapping at the beginning of the given section, possibly violating the sort order.
  void addMapping({required Mapping mapping, required String section}) {
    // Update mappingSections.
    if (!mappingSections.containsKey(section)) {
      mappingSections[section] = LinkedList();
    }
    mappingSections[section]!.addFirst(mapping);

    // Update _sourceToMappings.
    if (!_sourceToMappings.containsKey(mapping.source)) {
      _sourceToMappings[mapping.source] = [];
    }
    _sourceToMappings[mapping.source]!.add(mapping);
  }

  /// Clears a mappings from its section.
  void clearMapping(Mapping mapping) {
    // There should only be one instance of [mapping] in _sourceToMappings.
    _sourceToMappings[mapping.source]!.remove(mapping);

    // The mapping already knows which section it's in.
    mapping.unlink();
  }

  /// Updates the pronunciation text for a mapping and position it in the
  /// correct place in its [LinkedList] to retain the sort order.
  /// [mapping] must be a member of a linked list.
  void updatePronunciation({
    required Mapping mapping,
    required String newPronunciation,
  }) {
    // Update the pronunciation field.
    mapping.pronounciation = newPronunciation;

    // Reposition the mapping in its linked list.
    // We know the linked list has at least one element, namely [mapping].
    // If it is the only element, we don't need to do anything.
    if (mapping.list!.first.next == null) {
      return;
    }

    // There are at least two elements in the linked list.
    // Unlink [mapping] and insert it again into the linked list, preserving the sort order.
    final list = mapping.list!;
    mapping.unlink();
    list.insertPreservingSort(mapping);
  }

  /// Updates the source text for a mapping.
  void updateSource({
    required Mapping mapping,
    required String newSource,
  }) {
    // Update _sourceToMappings.
    _sourceToMappings[mapping.source]!.remove(mapping);
    if (!_sourceToMappings.containsKey(newSource)) {
      _sourceToMappings[newSource] = [];
    }
    _sourceToMappings[newSource]!.add(mapping);

    // Update the source field.
    mapping.source = newSource;
  }

  /// Updates the translation for a mapping.
  void updateTranslation({
    required Mapping mapping,
    required List<String> newTranslation,
  }) {
    mapping.translation = newTranslation;
  }

  // Initialise map as empty.
  FullMap()
      : mappingSections = {},
        _sourceToMappings = {};

  FullMap._allFields({
    required this.mappingSections,
  }) : _sourceToMappings = {} {
    // Ensure that the values of mappingSections are sorted linked lists.
    // TODO: remove this code soon and document the change, after any savefiles
    // have been migrated (overwritten with a version where this field is sorted).
    keyOfMapping(Mapping mapping) => mapping.pronounciation;
    for (final section in mappingSections.values) {
      if (section.isSortedBy(keyOfMapping)) {
        // If this section is sorted, we don't have to do anything.
        continue;
      }

      // Store the mappings in an array and unlink them from their linked list.
      final sectionList = section.toList();
      for (final mapping in sectionList) {
        mapping.unlink();
      }

      // Sort the array, then add back the mapping elements to the linked list.
      sectionList.sortBy(keyOfMapping);
      assert(section.isEmpty);
      section.addAll(sectionList);
    }

    // Populate _sourceToMappings using values from mappingSections.
    for (final section in mappingSections.values) {
      for (final mapping in section) {
        if (!_sourceToMappings.containsKey(mapping.source)) {
          _sourceToMappings[mapping.source] = [];
        }
        _sourceToMappings[mapping.source]!.add(mapping);
      }
    }
  }

  factory FullMap.fromJson(Map<String, dynamic> json) =>
      _$FullMapFromJson(json);

  Map<String, dynamic> toJson() => _$FullMapToJson(this);
}

extension InsertMappingIntoLinkedList on LinkedList<Mapping> {
  /// Assuming that this [LinkedList] is sorted by applying the default compare
  /// function to [Mapping.pronounciation], insert [mapping] into the linked
  /// list, preserving the sort order. [mapping] must not already be in any
  /// linked list.
  void insertPreservingSort(Mapping mapping) {
    // If the list is empty to begin with, this operation is trivial.
    if (isEmpty) {
      add(mapping);
      return;
    }

    // A special case is when the new element must be inserted at the beginning
    // of the list.
    if (mapping.pronounciation.compareTo(first.pronounciation) <= 0) {
      // In this case, mapping is ordered before first, or they are equivalent.
      first.insertBefore(mapping);
      return;
    }

    // Now we know that we can insert [mapping] *after some element of the linked list*.
    // We also know that [mapping] must be inserted after [first].

    var other = first;
    while (other.next != null &&
        mapping.pronounciation.compareTo(other.next!.pronounciation) > 0) {
      // Now we know that there is yet another element in the linked list after
      // other. We also know that [mapping] must be inserted after [other.next],
      // so it is certainly not inserted immediately after [other].
      // Move one element along.
      other = other.next!;
    }

    // At this point,
    // - either [other.next] == null, in which case [mapping] must be the last element in the linked list
    // - or [mapping] must be inserted before [other.next] (we already know it must be inserted after [other])
    other.insertAfter(mapping);
  }
}

enum SourceLanguage {
  chinese,
  alphabetic,
}
