import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final class Word extends LinkedListEntry<Word> {
  String source;
  String pronounciation = '-';
  String gloss = '-';

  Word({required this.source});
}

class Line {
  LinkedList<Word> words;

  Line({required this.words});

  // By default, a line is split by character into words.
  Line.fromString(String source) : words = LinkedList() {
    words.addAll(source
        .split('')
        .map((String characterString) => Word(source: characterString)));
  }
}

class Chunk {
  List<Line> lines;
  String translation = 'Lorem';

  Chunk({required this.lines});

  // By default, a chunk contains only one line.
  Chunk.fromString(String source) : lines = [Line.fromString(source)];
}

class FullText {
  List<Chunk> chunks;

  FullText({required this.chunks});

  // By default, a source text is delimited by newline characters into chunks.
  FullText.fromString(String source)
      : chunks = source
            .split('\n')
            .map((String chunkString) => Chunk.fromString(chunkString))
            .toList();
}

/// The currently-selected word in Translation Mode.
final selectedWordProvider =
    NotifierProvider<SelectedWord, Word?>(SelectedWord.new);

class SelectedWord extends Notifier<Word?> {
  @override
  Word? build() {
    // Set the initial state.
    return null;
  }

  /// Set a new word as the current selection.
  void set(Word w) {
    state = w;
  }

  /// Clear the curently-selected word.
  void clear() {
    state = null;
  }
}

final class Mapping extends LinkedListEntry<Mapping> {
  String pronounciation;
  String source;
  List<String> translation;

  Mapping({
    required this.pronounciation,
    required this.source,
    required this.translation,
  });
}

class FullMap {
  // TODO: protect against accidentally modifying this map.
  /// Maps from the name of a section to a linked list of mappings in that section.
  final Map<String, LinkedList<Mapping>> mappingSections;

  /// Maps from a source word to the list of mappings associated with that word, across all sections.
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
}

/// The currently-selected mapping in Map Mode.
final selectedMappingProvider =
    NotifierProvider<SelectedMapping, Mapping?>(SelectedMapping.new);

class SelectedMapping extends Notifier<Mapping?> {
  @override
  Mapping? build() {
    // Set the initial state.
    return null;
  }

  /// Set a new mapping as the current selection.
  void set(Mapping m) {
    state = m;
  }

  /// Clear the curently-selected mapping.
  void clear() {
    state = null;
  }
}
