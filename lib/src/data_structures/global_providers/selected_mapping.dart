import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_structures.dart';

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
