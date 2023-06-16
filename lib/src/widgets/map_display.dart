import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_structures.dart';
import 'common.dart';

/// Displays a mapping, allowing it to be edited while selected.
class MappingDisplay extends ConsumerStatefulWidget {
  const MappingDisplay({super.key, required this.mapping});

  final Mapping mapping;

  @override
  ConsumerState<MappingDisplay> createState() => _MappingDisplayState();
}

class _MappingDisplayState extends ConsumerState<MappingDisplay> {
  bool _textFieldsVisible = false;
  final _pronounciationController = TextEditingController();
  final _sourceController = TextEditingController();
  final _translationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initially, set the text field values to the existing strings.
    _pronounciationController.text = widget.mapping.pronounciation;
    _sourceController.text = widget.mapping.source;
    _translationController.text = widget.mapping.translation.join(';');

    // Add listeners to update these strings whenever the text field values change.
    _pronounciationController.addListener(() {
      widget.mapping.pronounciation = _pronounciationController.text;
    });
    _sourceController.addListener(() {
      widget.mapping.source = _sourceController.text;
    });
    _translationController.addListener(() {
      widget.mapping.translation = _translationController.text.split(';');
    });
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
        // If this mapping was already selected, clear the selection.
        if (ref.read(selectedMappingProvider) == widget.mapping) {
          ref.read(selectedMappingProvider.notifier).clear();
        }
        // Otherwise, update the currently-selected word.
        else {
          ref.read(selectedMappingProvider.notifier).set(widget.mapping);
        }
      },
      child: Row(children: [
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: _textFieldsVisible
              ? TextField(
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
  const MapDisplay({super.key, required this.map});

  final FullMap map;

  @override
  State<MapDisplay> createState() => _MapDisplayState();
}

class _MapDisplayState extends State<MapDisplay> {
  // The SizedBox widgets add extra padding at the top and bottom of the list.
  late final _sectionDisplayWidgets = [
    const SizedBox(height: 50),
    ...widget.map.mappingSections.entries.map((s) => Column(
          children: [
            // Name of this section.
            Text(
              s.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // The mappings in this section.
            ...s.value.map((m) => MappingDisplay(mapping: m)),
          ],
        )),
    const SizedBox(height: 50),
  ];

  @override
  Widget build(BuildContext context) {
    // Display the sections in a lazy list.
    return ListView.builder(
      itemCount: _sectionDisplayWidgets.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: _sectionDisplayWidgets[index],
        );
      },
    );
  }
}
