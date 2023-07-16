import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_structures.dart';

/// The currently-selected source language in the Settings.
final selectedLanguageProvider =
    NotifierProvider<SelectedLanguage, SourceLanguage>(SelectedLanguage.new);

class SelectedLanguage extends Notifier<SourceLanguage> {
  @override
  SourceLanguage build() {
    // Set the initial state.
    return SourceLanguage.chinese;
  }

  /// Set a new language as the current selection.
  void set(SourceLanguage l) {
    state = l;
  }
}
