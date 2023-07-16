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
        SourceLanguage.chinese => chunkString.split(''),
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
  /// Maps from the name of a section to a linked list of mappings in that section.
  final Map<String, LinkedList<Mapping>> mappingSections;

  /// Maps from a source word to the list of mappings associated with that word, across all sections.
  @JsonKey(includeFromJson: true, includeToJson: true)
  final Map<String, List<Mapping>> _sourceToMappings;

  List<Mapping>? souceToMappings(String source) => _sourceToMappings[source];

  /// Adds a mapping to the given section.
  void addMapping({required Mapping mapping, required String section}) {
    // Update mappingSections.
    if (!mappingSections.containsKey(section)) {
      mappingSections[section] = LinkedList();
    }
    mappingSections[section]!.add(mapping);

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

  /// Updates the source text for a mapping. The other fields can be modified in-place without going through this [FullMap] interface.
  void updateSource({required Mapping mapping, required String newSource}) {
    // Update _sourceToMappings.
    _sourceToMappings[mapping.source]!.remove(mapping);
    if (!_sourceToMappings.containsKey(newSource)) {
      _sourceToMappings[newSource] = [];
    }
    _sourceToMappings[newSource]!.add(mapping);

    // Update the source field.
    mapping.source = newSource;
  }

  // Initialise map as empty.
  FullMap()
      : mappingSections = {},
        _sourceToMappings = {};

  FullMap._allFields(
    // The first argument must be a positional argument because named arguments starting with an underscore are not allowed.
    this._sourceToMappings, {
    required this.mappingSections,
  });

  factory FullMap.fromJson(Map<String, dynamic> json) =>
      _$FullMapFromJson(json);

  Map<String, dynamic> toJson() => _$FullMapToJson(this);
}

enum SourceLanguage {
  chinese,
  alphabetic,
}