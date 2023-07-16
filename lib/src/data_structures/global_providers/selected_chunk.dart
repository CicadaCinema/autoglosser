import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_structures.dart';

/// The currently-selected chunk translation in Translation Mode.
final selectedChunkTranslationProvider =
    NotifierProvider<SelectedChunkTranslation, Word?>(
        SelectedChunkTranslation.new);

class SelectedChunkTranslation extends Notifier<Word?> {
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
