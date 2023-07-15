import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../save_string/desktop.dart'
    if (dart.library.html) '../save_string/web.dart' as save_string;

import 'package:autoglosser/src/common.dart';
import 'package:collection/collection.dart';
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
        // Also clear the selected translation chunk.
        ref.read(selectedChunkTranslationProvider.notifier).clear();
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

  // Only the last element of this list can have a [LineBreak], a [ChunkBreak] or a [PageBreak].
  final List<Word> line;

  @override
  State<LineDisplay> createState() => _LineDisplayState();
}

class _LineDisplayState extends State<LineDisplay> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: widget.line.map((w) => WordDisplay(word: w)).toList(),
    );
  }
}

/// A widget which displays the translation of a chunk, or a text field if this
/// chunk translation is selected.
class ChunkTranslationDisplay extends ConsumerStatefulWidget {
  ChunkTranslationDisplay({super.key, required this.lastWord})
      : chunkBreak = lastWord.breakKind as ChunkBreak;

  /// A reference to [lastWord.breakKind].
  final ChunkBreak chunkBreak;

  /// The last word of this chunk.
  ///
  /// The [Word.breakKind] of this [Word] is of type [ChunkBreak].
  final Word lastWord;

  @override
  ConsumerState<ChunkTranslationDisplay> createState() =>
      _ChunkTranslationDisplayState();
}

class _ChunkTranslationDisplayState
    extends ConsumerState<ChunkTranslationDisplay> {
  bool _textFieldVisible = false;
  final _translationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add a listener to update this string whenever the text field value changes.
    _translationController.addListener(() {
      widget.chunkBreak.chunkTranslation = _translationController.text;
    });
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for changes to the currently selected chunk translation.
    ref.listen<Word?>(selectedChunkTranslationProvider,
        (Word? prev, Word? next) {
      final previouslySelected = widget.lastWord == prev;
      final nowSelected = widget.lastWord == next;

      // Only rebuild this widget if the selected status of the word has changed.
      if (previouslySelected != nowSelected) {
        if (nowSelected) {
          // If this word is now selected, set the text field values to the existing pronounciation and gloss strings.
          _translationController.text = widget.chunkBreak.chunkTranslation;
        }

        setState(() {
          // Toggle selected status.
          _textFieldVisible = !_textFieldVisible;
        });
      }
    });
    return GestureDetector(
      onTap: () {
        // If this translation chunk was already selected, clear the selection.
        if (ref.read(selectedChunkTranslationProvider) == widget.lastWord) {
          ref.read(selectedChunkTranslationProvider.notifier).clear();
        }
        // Otherwise, update the currently-selected translation chunk.
        else {
          ref
              .read(selectedChunkTranslationProvider.notifier)
              .set(widget.lastWord);
        }
        // Also clear the selected word.
        ref.read(selectedWordProvider.notifier).clear();
      },
      child: _textFieldVisible
          ?
          // TODO: can we make this use intrinsic width? only one TextField of this type will be on-screen at any given time, maybe we can afford the performance cost
          SizedBox(
              width: 400,
              child: TextField(
                controller: _translationController,
                decoration: compactDecoration,
              ),
            )

          // The majority of the time we will only need to show just this one widget.
          : Text(widget.chunkBreak.chunkTranslation),
    );
  }
}

/// A widget which displays the source text of a chunk and its translation below.
class ChunkDisplay extends StatefulWidget {
  const ChunkDisplay({
    super.key,
    required this.chunk,
  });

  // Only the last element of this list can have a [ChunkBreak] or a [PageBreak].
  final List<Word> chunk;

  @override
  State<ChunkDisplay> createState() => _ChunkDisplayState();
}

class _ChunkDisplayState extends State<ChunkDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.chunk
              // Returns an Iterable<List<Word>> representing a list of lines.
              .splitAfter((Word word) => word.breakKind is LineBreak)
              // This cast is in fact necessary.
              // ignore: unnecessary_cast
              .map((List<Word> l) => LineDisplay(line: l) as Widget)
              .toList() +
          // FIXME: ensure .last does not throw an exception.
          [ChunkTranslationDisplay(lastWord: widget.chunk.last)],
    );
  }
}

class ButtonSidebar extends ConsumerStatefulWidget {
  const ButtonSidebar({
    super.key,
    required this.text,
    required this.replaceFullText,
    required this.map,
    required this.setState,
  });

  final FullText text;
  final void Function(FullText) replaceFullText;
  final FullMap map;

  /// Callback for updating the layout of the full text display.
  final void Function(void Function()) setState;

  @override
  ConsumerState<ButtonSidebar> createState() => _ButtonSidebarState();
}

class _ButtonSidebarState extends ConsumerState<ButtonSidebar> {
  bool _autoglossEnabled = true;

  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    // Ensure autoglossing is enabled and a word is selected and this word isn't the last one, before presenting autoglossing options to the user.
    final wordSelected = ref.watch(selectedWordProvider) != null;
    final canAutogloss = _autoglossEnabled &&
        wordSelected &&
        ref.watch(selectedWordProvider)!.next != null;

    // Produce an ElevatedButton for each translation within each mapping that matches the source of this word.
    final glossWidgets = <Widget>[];
    if (canAutogloss) {
      for (final Mapping mapping in widget.map
              .souceToMappings(ref.watch(selectedWordProvider)!.source) ??
          []) {
        for (final String translation in mapping.translation) {
          glossWidgets.add(const SizedBox(height: 12));
          glossWidgets.add(
            ElevatedButton(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child:
                    Text('Gloss with\n${mapping.pronounciation}\n$translation'),
              ),
              onPressed: () {
                // Move onto the next word, as below.
                final selectedWord = ref.read(selectedWordProvider)!;
                ref.read(selectedWordProvider.notifier).set(selectedWord.next!);
                // Set the pronounciation and translation.
                selectedWord.pronounciation = mapping.pronounciation;
                selectedWord.gloss = translation;
              },
            ),
          );
        }
      }
    }
    final autoglossingButtons = <Widget>[
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
    ];
    if (canAutogloss) {
      autoglossingButtons.addAll([
        const SizedBox(height: 12),
        ElevatedButton(
          child: const Text('Skip word'),
          onPressed: () {
            // Skip this word and move onto the next.
            final selectedWord = ref.read(selectedWordProvider);
            ref.read(selectedWordProvider.notifier).set(selectedWord!.next!);
          },
        ),
      ]);
      autoglossingButtons.addAll(glossWidgets);
    }

    // Note that we cannot build nice maps from String to Type and invoke constuctors dynamically, nor rely on .runtimeType, so we must settle for these ugly if statements.
    // Display the breakKind of the currently selected word.
    final BreakKind? selectedBreakKind =
        ref.watch(selectedWordProvider)?.breakKind;
    if (selectedBreakKind is PageBreak) {
      dropdownValue = breakKinds[3];
    } else if (selectedBreakKind is ChunkBreak) {
      dropdownValue = breakKinds[2];
    } else if (selectedBreakKind is LineBreak) {
      dropdownValue = breakKinds[1];
    } else if (selectedBreakKind is NoBreak) {
      dropdownValue = breakKinds[0];
    } else {
      assert(selectedBreakKind == null);
      dropdownValue = null;
    }
    // A dropdown button for changing the break kind of the currently-selected word.
    final breakSelectionDropdown = DropdownButton<String>(
      value: dropdownValue,
      onChanged: wordSelected
          ? (String? value) {
              widget.setState(() {
                final selectedWord = ref.read(selectedWordProvider)!;
                if (value == breakKinds[0]) {
                  selectedWord.breakKind = NoBreak();
                } else if (value == breakKinds[1]) {
                  selectedWord.breakKind = LineBreak();
                } else if (value == breakKinds[2]) {
                  selectedWord.breakKind = ChunkBreak();
                } else if (value == breakKinds[3]) {
                  selectedWord.breakKind = PageBreak();
                } else {
                  throw StateError('Unexpected selection $value.');
                }
              });
            }
          : null,
      items: breakKinds.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      disabledHint: const Text('No word selected'),
    );

    final selectedWord = ref.watch(selectedWordProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final canSplitWord = selectedWord != null &&
        switch (selectedLanguage) {
          SourceLanguage.chinese => selectedWord.source.length > 1,
          SourceLanguage.alphabetic => selectedWord.source.contains(' '),
        };
    final canJoinWord = selectedWord != null && selectedWord.next != null;
    final wordOperationButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: canSplitWord
              ? () {
                  // The source texts of the two new words.
                  late final String part1;
                  late final String part2;

                  switch (selectedLanguage) {
                    case SourceLanguage.chinese:
                      (part1, part2) = selectedWord.source.splitOnFirstChar();
                    case SourceLanguage.alphabetic:
                      (part1, part2) = selectedWord.source.splitOnSpace();
                  }

                  widget.setState(() {
                    // Replace the source text of the selected word.
                    ref.read(selectedWordProvider)!.source = part1;
                    // Create a new word after the selected one.
                    final newWord = Word(source: part2);
                    ref.read(selectedWordProvider)!.insertAfter(newWord);

                    // If the selected word's pronounciation had a space, split that too.
                    if (selectedWord.pronounciation.contains(' ')) {
                      final newPronounciation =
                          selectedWord.pronounciation.splitOnSpace();
                      ref.read(selectedWordProvider)!.pronounciation =
                          newPronounciation.$1;
                      newWord.pronounciation = newPronounciation.$2;
                    }

                    // If the selected word's gloss has a space, split that too.
                    if (selectedWord.gloss.contains(' ')) {
                      final newGloss = selectedWord.gloss.splitOnSpace();
                      ref.read(selectedWordProvider)!.gloss = newGloss.$1;
                      newWord.gloss = newGloss.$2;
                    }

                    // Finally, remove the current selection.
                    ref.read(selectedWordProvider.notifier).clear();
                  });
                }
              : null,
          child: const Text('split word'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: canJoinWord
              ? () {
                  widget.setState(() {
                    // Modify the fields of the selected word.
                    ref.read(selectedWordProvider)!.source =
                        switch (selectedLanguage) {
                      SourceLanguage.chinese =>
                        '${selectedWord.source}${selectedWord.next!.source}',
                      SourceLanguage.alphabetic =>
                        '${selectedWord.source} ${selectedWord.next!.source}',
                    };
                    ref.read(selectedWordProvider)!.pronounciation =
                        '${selectedWord.pronounciation} ${selectedWord.next!.pronounciation}';
                    ref.read(selectedWordProvider)!.gloss =
                        '${selectedWord.gloss} ${selectedWord.next!.gloss}';

                    // Remove the next word.
                    ref.read(selectedWordProvider)!.next!.unlink();

                    // Finally, remove the current selection.
                    ref.read(selectedWordProvider.notifier).clear();
                  });
                }
              : null,
          child: const Text('join word'),
        ),
      ],
    );

    // NOTE: we have a very similar implemenation for saving and loading the FullMap.
    final saveLoadButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            save_string.save(
              content: jsonEncode(widget.text.toJson()),
              filename: 'my-text.agtext',
            );
          },
          child: const Text('save'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['agtext'],
            ).then((FilePickerResult? result) {
              if (result == null) {
                // User cancelled the selection.
                return;
              }
              final jsonString =
                  File(result.files.single.path!).readAsStringSync();
              final serialisedText = json.decode(jsonString);
              widget.replaceFullText(FullText.fromJson(serialisedText));
            });
          },
          child: const Text('load'),
        ),
      ],
    );

    return SizedBox(
      width: 300,
      child: Column(
        children: [
          saveLoadButtons,
          const Divider(),
          wordOperationButtons,
          const Divider(),
          breakSelectionDropdown,
          const Divider(),
          ...autoglossingButtons,
        ],
      ),
    );
  }
}

class TextDisplay extends StatefulWidget {
  const TextDisplay({
    super.key,
    required this.text,
    required this.replaceFullText,
    required this.map,
  });

  final FullText text;
  final void Function(FullText) replaceFullText;
  final FullMap map;

  @override
  State<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends State<TextDisplay> {
  @override
  Widget build(BuildContext context) {
    final chunkDisplayWidgets = widget.text.allWords
        // Returns an Iterable<List<Word>> representing a list of chunks.
        .splitAfter((Word word) => word.breakKind is ChunkBreak)
        .map((List<Word> c) => ChunkDisplay(chunk: c))
        .toList();

    // Display the chunks in a lazy list.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ButtonSidebar(
            text: widget.text,
            replaceFullText: widget.replaceFullText,
            map: widget.map,
            setState: setState,
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
