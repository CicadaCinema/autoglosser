import 'dart:collection';
import 'dart:math';

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

const characterMap = {
  "'": 1,
  'A': 2,
  'a': 3,
  'Ā': 4,
  'ā': 5,
  'Á': 6,
  'á': 7,
  'Ǎ': 8,
  'ǎ': 9,
  'À': 10,
  'à': 11,
  'B': 12,
  'b': 13,
  'C': 14,
  'c': 15,
  'D': 16,
  'd': 17,
  'E': 18,
  'e': 19,
  'Ē': 20,
  'ē': 21,
  'É': 22,
  'é': 23,
  'Ě': 24,
  'ě': 25,
  'È': 26,
  'è': 27,
  'F': 28,
  'f': 29,
  'G': 30,
  'g': 31,
  'H': 32,
  'h': 33,
  'I': 34,
  'i': 35,
  'ī': 36,
  'í': 37,
  'ǐ': 38,
  'ì': 39,
  'J': 40,
  'j': 41,
  'K': 42,
  'k': 43,
  'L': 44,
  'l': 45,
  'M': 46,
  'm': 47,
  'N': 48,
  'n': 49,
  'O': 50,
  'o': 51,
  'ō': 52,
  'ó': 53,
  'ǒ': 54,
  'ò': 55,
  'P': 56,
  'p': 57,
  'Q': 58,
  'q': 59,
  'R': 60,
  'r': 61,
  'S': 62,
  's': 63,
  'T': 64,
  't': 65,
  'U': 66,
  'u': 67,
  'ū': 68,
  'ú': 69,
  'ǔ': 70,
  'ù': 71,
  'Ü': 72,
  'ü': 73,
  'ǖ': 74,
  'ǘ': 75,
  'ǚ': 76,
  'ǜ': 77,
  'V': 78,
  'v': 79,
  'W': 80,
  'w': 81,
  'X': 82,
  'x': 83,
  'Y': 84,
  'y': 85,
  'Z': 86,
  'z': 87,
};

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

// TODO: Can these classes all extend one another?
// This may make the method FullText.toTex() slightly cleaner.
// Will this be useful anywhere else?
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
final class Mapping extends LinkedListEntry<Mapping>
    implements Comparable<Mapping> {
  // TODO: remove thees three setters (make them private instead), instead force the user to go through the [FullMap] interface.
  String pronounciation;
  String source;
  // TODO: make this a [Set].
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

  @override
  int compareTo(Mapping other) {
    // Iterate over the common indexes in the two pronunciation strings.
    for (int i = 0;
        i < min(pronounciation.length, other.pronounciation.length);
        i++) {
      final charComparison = switch ((
        characterMap[pronounciation[i]],
        characterMap[other.pronounciation[i]],
      )) {
        // If both characters are in the map, compare them using their inexes.
        (int thisCharIndex, int otherCharIndex) =>
          thisCharIndex.compareTo(otherCharIndex),
        // If one character is not in the map, it should be ordered last.
        // Here, `this` should come first.
        (int _, null) => -1,
        // Here, `other` should come first.
        (null, int _) => 1,
        // If neither character is in the map, then use the existing [String] logic for this.
        (null, null) => pronounciation[i].compareTo(other.pronounciation[i]),
      };

      // In this case, one character clearly comes before the other.
      // Otherwise, continue the loop.
      if (charComparison != 0) {
        return charComparison;
      }
    }

    // If we have reached this point, it means that one pronunciation is a substring of the other.
    // The shorter string lexicographically precedes the longer string.
    // For example, if `this` is longer than `other`, then a positive integer will be returned,
    // since `other` is the shorter string and `this` is ordered after `other`.
    return pronounciation.length - other.pronounciation.length;
  }
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

  /// Returns the number of mappings stored with this source word.
  int mappingCountWithSource(String source) {
    final mappings = _sourceToMappings[source];
    if (mappings == null) {
      return 0;
    } else {
      return mappings.length;
    }
  }

  /// Adds a mapping to the given section, maintaining the sort order.
  void addMapping({required Mapping mapping, required String section}) {
    // Update mappingSections.
    if (!mappingSections.containsKey(section)) {
      mappingSections[section] = LinkedList();
    }
    mappingSections[section]!.add(mapping);

    // Ensure that the new entry is initially correctly positioned.
    // This method re-positions it in its linked list if necessary to maintain
    // the sort order.
    updatePronunciation(
      mapping: mapping,
      newPronunciation: mapping.pronounciation,
    );

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
  // TODO: consider renaming the FullMap.update*() methods to FullMap.replace*().
  void updatePronunciation({
    required Mapping mapping,
    required String newPronunciation,
  }) {
    // Update the pronunciation field.
    mapping.pronounciation = applyToneMarks(newPronunciation);

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

  /// Adds a translation to a mapping.
  /// If the translation is already present, doesn't do anything.
  void addToTranslation({
    required Mapping mapping,
    required String translation,
  }) {
    if (mapping.translation.contains(translation)) {
      return;
    }
    mapping.translation.add(translation);
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
    for (final section in mappingSections.values) {
      if (section.isSorted((a, b) => a.compareTo(b))) {
        // If this section is sorted, we don't have to do anything.
        continue;
      }

      // Store the mappings in an array and unlink them from their linked list.
      final sectionList = section.toList();
      for (final mapping in sectionList) {
        mapping.unlink();
      }

      // Sort the array, then add back the mapping elements to the linked list.
      sectionList.sort();
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
  /// Assuming that this [LinkedList] is sorted, insert [mapping] into the
  /// linked list, preserving the sort order. [mapping] must not already be in
  /// any linked list.
  void insertPreservingSort(Mapping mapping) {
    // If the list is empty to begin with, this operation is trivial.
    if (isEmpty) {
      add(mapping);
      return;
    }

    // A special case is when the new element must be inserted at the beginning
    // of the list.
    if (mapping.compareTo(first) <= 0) {
      // In this case, mapping is ordered before first, or they are equivalent.
      first.insertBefore(mapping);
      return;
    }

    // Now we know that we can insert [mapping] *after some element of the linked list*.
    // We also know that [mapping] must be inserted after [first].

    var other = first;
    while (other.next != null && mapping.compareTo(other.next!) > 0) {
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

const _pinyinPronunciationMap = {
  'a1': 'ā',
  'a2': 'á',
  'a3': 'ǎ',
  'a4': 'à',
  'A1': 'Ā',
  'A2': 'Á',
  'A3': 'Ǎ',
  'A4': 'À',
  'o1': 'ō',
  'o2': 'ó',
  'o3': 'ǒ',
  'o4': 'ò',
  'e1': 'ē',
  'e2': 'é',
  'e3': 'ě',
  'e4': 'è',
  'E1': 'Ē',
  'E2': 'É',
  'E3': 'Ě',
  'E4': 'È',
  'i1': 'ī',
  'i2': 'í',
  'i3': 'ǐ',
  'i4': 'ì',
  'u1': 'ū',
  'u2': 'ú',
  'u3': 'ǔ',
  'u4': 'ù',
  'v1': 'ǖ',
  'v2': 'ǘ',
  'v3': 'ǚ',
  'v4': 'ǜ',
};

// TODO: ensure this function is as fast as can be, or else remove this TODO to indicate that performance is not important here.
/// Applies tone marks according to the Pinyin lookup table.
String applyToneMarks(String pronunciation) {
  var result = pronunciation;
  for (final conversionEntry in _pinyinPronunciationMap.entries) {
    result = result.replaceAll(conversionEntry.key, conversionEntry.value);
  }
  // We deal with this final case manually at the end!
  return result.replaceAll('v', 'ü');
}
