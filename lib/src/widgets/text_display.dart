import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_structures.dart';
import 'common.dart';

/// Displays a source word, its pronounciation and its gloss, allowing the
/// pronounciation and gloss to be edited while the word is selected.
class WordDisplay extends ConsumerStatefulWidget {
  const WordDisplay({super.key, required this.word});

  final Word word;

  @override
  ConsumerState<WordDisplay> createState() => _WordDisplayState();
}

class _WordDisplayState extends ConsumerState<WordDisplay> {
  bool _textFieldsVisible = false;
  final _pronounciationController = TextEditingController();
  final _glossController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to update these strings whenever the text field values change.
    _pronounciationController.addListener(() {
      widget.word.pronounciation = _pronounciationController.text;
    });
    _glossController.addListener(() {
      widget.word.gloss = _glossController.text;
    });
  }

  @override
  void dispose() {
    _pronounciationController.dispose();
    _glossController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes to the currently selected word.
    ref.listen<Word?>(selectedWordProvider, (Word? prev, Word? next) {
      final previouslySelected = widget.word == prev;
      final nowSelected = widget.word == next;
      // Only rebuild this widget if the selected status of the word has changed.
      if (previouslySelected != nowSelected) {
        if (nowSelected) {
          // If this word is now selected, set the text field values to the existing pronounciation and gloss strings.
          _pronounciationController.text = widget.word.pronounciation;
          _glossController.text = widget.word.gloss;
        }

        setState(() {
          // Toggle selected status.
          _textFieldsVisible = !_textFieldsVisible;
        });
      }
    });

    return GestureDetector(
      onTap: () {
        // If this word was already selected, clear the selection.
        if (ref.read(selectedWordProvider) == widget.word) {
          ref.read(selectedWordProvider.notifier).clear();
        }
        // Otherwise, update the currently-selected word.
        else {
          ref.read(selectedWordProvider.notifier).set(widget.word);
        }
      },
      child: _textFieldsVisible
          ? Column(
              children: [
                Text(widget.word.source),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _pronounciationController,
                    decoration: compactDecoration,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _glossController,
                    decoration: compactDecoration,
                  ),
                ),
              ],
            )
          // The majority of the time we will only need to show just this one widget.
          : Text(
              '${widget.word.source}\n${widget.word.pronounciation}\n${widget.word.gloss}'),
    );
  }
}

class LineDisplay extends StatefulWidget {
  const LineDisplay({super.key, required this.line});

  final Line line;

  @override
  State<LineDisplay> createState() => _LineDisplayState();
}

class _LineDisplayState extends State<LineDisplay> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: widget.line.words.map((w) => WordDisplay(word: w)).toList(),
    );
  }
}

class ChunkDisplay extends StatefulWidget {
  const ChunkDisplay({super.key, required this.chunk});

  final Chunk chunk;

  @override
  State<ChunkDisplay> createState() => _ChunkDisplayState();
}

class _ChunkDisplayState extends State<ChunkDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.chunk.lines.map((l) => LineDisplay(line: l)),
        Text(widget.chunk.translation),
      ],
    );
  }
}

class TextDisplay extends StatefulWidget {
  const TextDisplay({super.key, required this.text, required this.map});

  final FullText text;
  final FullMap map;

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  bool _autoglossEnabled = true;

  @override
  Widget build(BuildContext context) {
    final chunkDisplayWidgets =
        widget.text.chunks.map((c) => ChunkDisplay(chunk: c)).toList();

    // Display the chunks in a lazy list.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Consumer(
            builder: (context, ref, child) {
              // Ensure autoglossing is enabled and a word is selected and this word isn't the last one in its line, before presenting options to the user.
              // TODO: reorganise data strunctures once again to enable autoglossing across lines and chunks.
              final canAutogloss = _autoglossEnabled &&
                  ref.watch(selectedWordProvider) != null &&
                  ref.watch(selectedWordProvider)!.next != null;

              // Produce an ElevatedButton for each translation within each mapping that matches the source of this word.
              final glossWidgets = <Widget>[];
              if (canAutogloss) {
                for (final Mapping mapping in widget.map.souceToMappings(
                        ref.watch(selectedWordProvider)!.source) ??
                    []) {
                  for (final String translation in mapping.translation) {
                    glossWidgets.add(const SizedBox(height: 12));
                    glossWidgets.add(
                      ElevatedButton(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                              'Gloss with\n${mapping.pronounciation}\n$translation'),
                        ),
                        onPressed: () {
                          // Move onto the next word, as below.
                          final selected = ref.read(selectedWordProvider);
                          ref
                              .read(selectedWordProvider.notifier)
                              .set(selected!.next!);
                          // Set the pronounciation and translation.
                          selected.pronounciation = mapping.pronounciation;
                          selected.gloss = translation;
                        },
                      ),
                    );
                  }
                }
              }

              return SizedBox(
                width: 200,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable autoglossing'),
                      value: _autoglossEnabled,
                      onChanged: (bool value) {
                        // This is called when the user toggles the switch.
                        setState(() {
                          _autoglossEnabled = value;
                        });
                      },
                    ),
                    ...canAutogloss
                        ? [
                            const SizedBox(
                              height: 12,
                            ),
                            ElevatedButton(
                              child: const Text('Skip word'),
                              onPressed: () {
                                // Skip this word and move onto the next.
                                final selected = ref.read(selectedWordProvider);
                                ref
                                    .read(selectedWordProvider.notifier)
                                    .set(selected!.next!);
                              },
                            ),
                          ]
                        : [],
                    ...canAutogloss ? glossWidgets : [],
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chunkDisplayWidgets.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: chunkDisplayWidgets[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
