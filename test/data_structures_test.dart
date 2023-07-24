import 'package:autoglosser/src/common.dart';
import 'package:autoglosser/src/data_structures/data_structures.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

const alphabeticString = 'The quick brown fox jumped over the lazy dog.';
const chineseString = 'ab c';

void main() {
  test(
    'text should be split into words if source language is set to alphabetic',
    () {
      final text = FullText.fromString(
        source: alphabeticString,
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
        source: chineseString,
        sourceLanguage: SourceLanguage.chinese,
      );

      final expectedWords = ['a', 'b', ' ', 'c'];

      expect(text.allWords.length, equals(expectedWords.length));
      for (final (int index, Word word) in text.allWords.indexed) {
        expect(word.source, equals(expectedWords[index]));
      }
    },
  );

  test(
    'a text should survive a round trip to-from JSON',
    () {
      final alphabeticText = FullText.fromString(
        source: alphabeticString,
        sourceLanguage: SourceLanguage.alphabetic,
      );
      final chineseText = FullText.fromString(
        source: chineseString,
        sourceLanguage: SourceLanguage.chinese,
      );

      for (final originalText in [alphabeticText, chineseText]) {
        // Make some changes to the fields.
        originalText.allWords.first.source = 'firstSource';
        originalText.allWords.first.pronounciation = 'firstPronounciation';
        originalText.allWords.first.gloss = 'firstGloss';

        originalText.allWords.last.source = 'lastSource';
        originalText.allWords.last.pronounciation = 'lastPronounciation';
        originalText.allWords.last.gloss = 'lastGloss';

        // We expect each text to have at least 4 words.
        originalText.allWords.first.breakKind =
            PageBreak(chunkTranslation: 'index 0 pageBreak');
        originalText.allWords.first.next!.breakKind =
            ChunkBreak(chunkTranslation: 'index 1 chunkBreak');
        originalText.allWords.first.next!.next!.breakKind = LineBreak();
        originalText.allWords.first.next!.next!.next!.breakKind = NoBreak();

        final json = originalText.toJson();
        final resultingText = FullText.fromJson(json);

        expect(originalText.allWords.length,
            equals(resultingText.allWords.length));
        final originalWords = originalText.allWords.toList();
        final resultingWords = resultingText.allWords.toList();

        // Compare the fields of each word.
        for (var i = 0; i < originalWords.length; i++) {
          expect(originalWords[i].equals(resultingWords[i]), isTrue);
        }
      }
    },
  );

  test(
    'a map should survive a round trip to-from JSON',
    () {
      final originalMap = FullMap();

      final a1 =
          Mapping(pronounciation: 'a', source: 'b', translation: ['c1', 'c2']);
      final a2 = Mapping(pronounciation: 'd', source: 'e', translation: ['f']);
      final b = Mapping(pronounciation: 'g', source: 'h', translation: ['i']);

      originalMap.addMapping(mapping: a1, section: 'sectionA');
      originalMap.addMapping(mapping: a2, section: 'sectionA');
      originalMap.addMapping(mapping: b, section: 'sectionB');

      final json = originalMap.toJson();

      // We don't want to save FullMap._sourceToMappings because this field
      // must be generated from FullMap.mappingSections.
      // We later rely on the fact that these two fields will contain pairs of
      // identical objects of type Mapping.
      expect(json['sourceToMappings'], isNull);
      expect(json['_sourceToMappings'], isNull);

      final resultingMap = FullMap.fromJson(json);

      expect(
        const SetEquality().equals(
          resultingMap.mappingSections.keys.toSet(),
          {'sectionA', 'sectionB'},
        ),
        isTrue,
      );

      expect(resultingMap.mappingSections['sectionA']!.length, 2);
      expect(resultingMap.mappingSections['sectionB']!.length, 1);

      final wantA1 = resultingMap.mappingSections['sectionA']!.first;
      final wantA2 = resultingMap.mappingSections['sectionA']!.first.next!;
      final wantB = resultingMap.mappingSections['sectionB']!.first;
      expect(wantA1.equals(a1), isTrue);
      expect(wantA2.equals(a2), isTrue);
      expect(wantB.equals(b), isTrue);

      expect(
        identical(resultingMap.souceToMappings(wantA1.source)!.single, wantA1),
        isTrue,
      );
      expect(
        identical(resultingMap.souceToMappings(wantA2.source)!.single, wantA2),
        isTrue,
      );
      expect(
        identical(resultingMap.souceToMappings(wantB.source)!.single, wantB),
        isTrue,
      );
    },
  );

  test(
    'text containing characters outside the Basic Multilingual Plane (plane 0) should be split correctly',
    () {
      const a = 'a';
      const b = 'b';
      const c = 'c';
      const clef = '\u{1D11E}';
      const common = '\u{597D}';
      const rare = '\u{26BBC}';

      expect(a.length, equals(1));
      expect(b.length, equals(1));
      expect(c.length, equals(1));
      expect(clef.length, equals(2));
      expect(common.length, equals(1));
      expect(rare.length, equals(2));

      expect(a.runes.length, equals(1));
      expect(b.runes.length, equals(1));
      expect(c.runes.length, equals(1));
      expect(clef.runes.length, equals(1));
      expect(common.runes.length, equals(1));
      expect(rare.runes.length, equals(1));

      expect((a + b + c).splitOnFirstRune(), equals((a, b + c)));
      expect((a + clef).splitOnFirstRune(), equals((a, clef)));
      expect((clef + a).splitOnFirstRune(), equals((clef, a)));

      expect(
        (common + rare).splitOnFirstRune(),
        equals((common, rare)),
      );
      expect(
        (rare + common).splitOnFirstRune(),
        equals((rare, common)),
      );

      expect(
        (clef + common).splitOnFirstRune(),
        equals((clef, common)),
      );
      expect(
        (common + clef).splitOnFirstRune(),
        equals((common, clef)),
      );

      expect(
        (clef + rare).splitOnFirstRune(),
        equals((clef, rare)),
      );
      expect(
        (rare + clef).splitOnFirstRune(),
        equals((rare, clef)),
      );
    },
  );
}
