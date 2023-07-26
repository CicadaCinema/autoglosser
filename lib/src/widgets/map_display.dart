import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common.dart';
import '../data_structures/data_structures.dart';
import '../save_string/desktop.dart'
    if (dart.library.html) '../save_string/web.dart' as save_string;
import 'common.dart';

/// Displays a mapping, allowing it to be edited while selected.
class MappingDisplay extends ConsumerStatefulWidget {
  const MappingDisplay({
    super.key,
    required this.mapping,
    required this.map,
    required this.mapDisplaySetState,
  });

  final Mapping mapping;
  final FullMap map;

  /// Callback for updating the layout of the full map display.
  final void Function(void Function()) mapDisplaySetState;

  @override
  ConsumerState<MappingDisplay> createState() => _MappingDisplayState();
}

class _MappingDisplayState extends ConsumerState<MappingDisplay> {
  late bool _textFieldsVisible;
  final _pronounciationController = TextEditingController();
  final _sourceController = TextEditingController();
  final _translationController = TextEditingController();

  // Called when the user indicates they have finished editing one of the three
  // text fields, typically by pressing the enter key.
  // Updates all the fields in the [Mapping].
  void _onSubmitted(String _) {
    // Clear the selection
    ref.read(selectedMappingProvider.notifier).clear();

    // Update the full map display, but only if the pronunciation has been modified.
    // The fields must be updated using the [FullMap] interface.
    final map = widget.map;
    final mapping = widget.mapping;
    final pronunciationModified =
        mapping.pronounciation != _pronounciationController.text;
    map.updatePronunciation(
      mapping: mapping,
      newPronunciation: _pronounciationController.text,
    );
    map.updateSource(
      mapping: mapping,
      newSource: _sourceController.text,
    );
    map.updateTranslation(
      mapping: mapping,
      newTranslation: _translationController.text.split(';'),
    );

    // Rebuild widgets.
    if (pronunciationModified) {
      // In this case, all the [MappingDisplay] widgets are rebuilt.
      widget.mapDisplaySetState(() {});
    } else {
      // Otherwise, only this widget is rebuilt.
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // Initially, set the text field values to the existing strings.
    _pronounciationController.text = widget.mapping.pronounciation;
    _sourceController.text = widget.mapping.source;
    _translationController.text = widget.mapping.translation.join(';');

    // Sometimes this mapping may be selected upon creation.
    _textFieldsVisible = ref.read(selectedMappingProvider) == widget.mapping;
  }

  @override
  void dispose() {
    _pronounciationController.dispose();
    _sourceController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes to the currently selected mapping.
    // This is so that this mapping can hide its text fields when another one is selected.
    // TODO: if increased rebuilds are not an issue, we can just use ref.watch, using it to set a local variable _textFieldsVisible inside this build method. The alternative we are using now is to ref.read to obtain the initial value, then ref.listen to call a custom function and decide manually to only rebuild when the selection status changes.
    ref.listen<Mapping?>(selectedMappingProvider,
        (Mapping? prev, Mapping? next) {
      final previouslySelected = widget.mapping == prev;
      final nowSelected = widget.mapping == next;
      // Only rebuild this widget if the selected status of the mapping has changed.
      if (previouslySelected != nowSelected) {
        setState(() {
          // Toggle selected status.
          _textFieldsVisible = !_textFieldsVisible;
        });
      }
    });

    return GestureDetector(
      onTap: () {
        // Only react to clicks if no mapping was selected previously.
        // In this case, assign this mapping as selected.
        if (ref.read(selectedMappingProvider) == null) {
          ref.read(selectedMappingProvider.notifier).set(widget.mapping);
        }
      },
      child: Row(children: [
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _textFieldsVisible
              ? TextField(
                  onSubmitted: _onSubmitted,
                  controller: _pronounciationController,
                  decoration: compactDecoration,
                )
              : Text(widget.mapping.pronounciation),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: _textFieldsVisible
              ? TextField(
                  onSubmitted: _onSubmitted,
                  controller: _sourceController,
                  decoration: compactDecoration,
                )
              : Text(widget.mapping.source),
        ),
        Flexible(
          flex: 5,
          fit: FlexFit.tight,
          child: _textFieldsVisible
              ? TextField(
                  onSubmitted: _onSubmitted,
                  controller: _translationController,
                  decoration: compactDecoration,
                )
              : Text(widget.mapping.translation.join(';')),
        ),
      ]),
    );
  }
}

class MapDisplay extends StatefulWidget {
  const MapDisplay({
    super.key,
    required this.map,
    required this.replaceFullMap,
  });

  final FullMap map;
  final void Function(FullMap) replaceFullMap;

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> {
  @override
  Widget build(BuildContext context) {
    // The SizedBox widgets add extra padding at the top and bottom of the list.
    final sectionDisplayWidgets = widget.map.mappingSections.entries
        .map((s) => [
              // Name of this section.
              Text(
                s.key,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // The mappings in this section.
              ...s.value.map((m) => MappingDisplay(
                    key: UniqueKey(),
                    mapping: m,
                    map: widget.map,
                    mapDisplaySetState: setState,
                  )),
            ])
        // Flatten this list of lists.
        .expand((i) => i)
        .toList();

    // Display the sections in a lazy list.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              // True if there is some selected mapping.
              final someMappingSelected =
                  ref.watch(selectedMappingProvider) != null;

              return Row(
                children: [
                  // NOTE: we have a very similar implemenation for saving and loading the FullText.
                  ElevatedButton(
                    onPressed: someMappingSelected
                        ? null
                        : () {
                            save_string.save(
                              content: jsonEncode(widget.map.toJson()),
                              filename: 'my-map.agmap',
                            );
                          },
                    child: const Text('save'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: someMappingSelected
                        ? null
                        : () {
                            ref.read(selectedMappingProvider.notifier).clear();
                            FilePicker.platform
                                .pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['agmap'],
                                )
                                .then(filePickerResultToString)
                                .then(json.decode)
                                .then((dynamic serialisedText) =>
                                    widget.replaceFullMap(
                                        FullMap.fromJson(serialisedText)));
                          },
                    child: const Text('load'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: someMappingSelected
                        ? null
                        : () {
                            // Add a new mapping and set it as selected.
                            final newMapping = Mapping(
                                pronounciation: 'a',
                                source: 'b',
                                translation: ['c']);
                            setState(() {
                              widget.map.addMapping(
                                  mapping: newMapping, section: 'Default');
                            });
                            ref
                                .read(selectedMappingProvider.notifier)
                                .set(newMapping);
                          },
                    child: const Text('Add mapping to the general section'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: someMappingSelected
                        ? () {
                            // Retrieve the mapping to remove and remove the selection.
                            final mappingToRemove =
                                ref.read(selectedMappingProvider);
                            ref.read(selectedMappingProvider.notifier).clear();

                            // The condition `ref.watch(selectedMappingProvider) == null` above serves as a null check.
                            setState(() {
                              widget.map.clearMapping(mappingToRemove!);
                            });
                          }
                        : null,
                    child: const Text('Remove selected mapping'),
                  ),
                ],
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sectionDisplayWidgets.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: sectionDisplayWidgets[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
