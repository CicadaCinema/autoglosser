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
    // Initially, set the text field values to the existing pronounciation and gloss strings.
    _pronounciationController.text = widget.word.pronounciation;
    _glossController.text = widget.word.gloss;

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
      child: Column(
        children: [
          Text(widget.word.source),
          _textFieldsVisible
              ? SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _pronounciationController,
                    decoration: compactDecoration,
                  ),
                )
              : Text(widget.word.pronounciation),
          _textFieldsVisible
              ? SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _glossController,
                    decoration: compactDecoration,
                  ),
                )
              : Text(widget.word.gloss),
        ],
      ),
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
    return Row(
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

/// A horizontal scroll container with a visible scroll bar.
class HorizontalScroll extends StatefulWidget {
  const HorizontalScroll({super.key, required this.child});

  final Widget child;

  @override
  State<HorizontalScroll> createState() => _HorizontalScrollState();
}

class _HorizontalScrollState extends State<HorizontalScroll> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}

class TextDisplay extends ConsumerStatefulWidget {
  const TextDisplay({super.key, required this.text});

  final FullText text;

  @override
  ConsumerState<TextDisplay> createState() => _TextDisplayState();
}

class _TextDisplayState extends ConsumerState<TextDisplay> {
  @override
  Widget build(BuildContext context) {
    // The SizedBox widgets add extra padding at the top and bottom of the list.
    final chunkDisplayWidgets = [
      const SizedBox(height: 50),
      ...widget.text.chunks.map((c) => ChunkDisplay(chunk: c)),
      const SizedBox(height: 50),
    ];

    // Display the chunks in a lazy list.
    return Row(
      children: [
        ElevatedButton(
          child: const Text('Autogloss'),
          onPressed: () {
            // FIXME: remove this and actually implement autoglossing
            final selected = ref.read(selectedWordProvider);
            ref.read(selectedWordProvider.notifier).set(selected!.next!);
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: chunkDisplayWidgets.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: HorizontalScroll(child: chunkDisplayWidgets[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
