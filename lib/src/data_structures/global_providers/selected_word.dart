import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_structures.dart';

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
