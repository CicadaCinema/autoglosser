import 'package:autoglosser/src/data_structures.dart';
import 'package:test/test.dart';

void main() {
  test(
    'text should be split into words if source language is set to alphabetic',
    () {
      final text = FullText.fromString(
        source: 'The quick brown fox jumped over the lazy dog.',
        sourceLanguage: SourceLanguage.alphabetic,
      );

      final expectedWords = [
        'The',
        'quick',
        'brown',
        'fox',
        'jumped',
        'over',
        'the',
        'lazy',
        'dog.',
      ];

      expect(text.allWords.length, equals(expectedWords.length));
      for (final (int index, Word word) in text.allWords.indexed) {
        expect(word.source, equals(expectedWords[index]));
      }
    },
  );

  test(
    'text should be split into characters if source language is set to chinese',
    () {
      final text = FullText.fromString(
        source: 'ab c',
        sourceLanguage: SourceLanguage.chinese,
      );

      final expectedWords = ['a', 'b', ' ', 'c'];

      expect(text.allWords.length, equals(expectedWords.length));
      for (final (int index, Word word) in text.allWords.indexed) {
        expect(word.source, equals(expectedWords[index]));
      }
    },
  );
}
