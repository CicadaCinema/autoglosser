import 'package:flutter_riverpod/flutter_riverpod.dart';

class Word {
  String source;
  String pronounciation = '-';
  String gloss = '-';

  Word({required this.source});
}

class Line {
  List<Word> words;

  Line({required this.words});

  // By default, a line is split by character into words.
  Line.fromString(String source)
      : words = source
            .split('')
            .map((String characterString) => Word(source: characterString))
            .toList();
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
