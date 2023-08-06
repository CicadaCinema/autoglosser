import 'dart:collection';

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

      originalMap.addMapping(mapping: a2, section: 'sectionA');
      originalMap.addMapping(mapping: a1, section: 'sectionA');
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

  group(
    'a Mapping should be able to be inserted into an already-sorted LinkedList<Mapping> object',
    () {
      late Mapping a;
      late Mapping b;
      late Mapping bOther;
      late Mapping b_;
      late Mapping c;
      late Mapping d;
      late Mapping d_;
      late Mapping e;
      late Mapping f;
      late Mapping f_;
      late Mapping g;
      late LinkedList<Mapping> list;
      late LinkedList<Mapping> listSingleElement;
      late LinkedList<Mapping> listEmpty;
      late Function eq;

      setUp(() {
        a = Mapping(pronounciation: 'a', source: '', translation: []);
        b = Mapping(pronounciation: 'b', source: '', translation: []);
        bOther = Mapping(pronounciation: 'b', source: '', translation: []);
        b_ = Mapping(pronounciation: 'b', source: '', translation: []);
        c = Mapping(pronounciation: 'c', source: '', translation: []);
        d = Mapping(pronounciation: 'd', source: '', translation: []);
        d_ = Mapping(pronounciation: 'd', source: '', translation: []);
        e = Mapping(pronounciation: 'e', source: '', translation: []);
        f = Mapping(pronounciation: 'f', source: '', translation: []);
        f_ = Mapping(pronounciation: 'f', source: '', translation: []);
        g = Mapping(pronounciation: 'g', source: '', translation: []);

        list = LinkedList();
        list.add(b);
        list.add(d);
        list.add(f);

        listSingleElement = LinkedList();
        listSingleElement.add(bOther);

        listEmpty = LinkedList();

        eq = const ListEquality().equals;
      });

      test(
        'insert a',
        () {
          list.insertPreservingSort(a);
          expect(
            eq(list.map((m) => m.pronounciation).toList(),
                ['a', 'b', 'd', 'f']),
            isTrue,
          );
        },
      );

      test(
        'insert c',
        () {
          list.insertPreservingSort(c);
          expect(
            eq(list.map((m) => m.pronounciation).toList(),
                ['b', 'c', 'd', 'f']),
            isTrue,
          );
        },
      );

      test(
        'insert e',
        () {
          list.insertPreservingSort(e);
          expect(
            eq(list.map((m) => m.pronounciation).toList(),
                ['b', 'd', 'e', 'f']),
            isTrue,
          );
        },
      );

      test(
        'insert g',
        () {
          list.insertPreservingSort(g);
          expect(
            eq(list.map((m) => m.pronounciation).toList(),
                ['b', 'd', 'f', 'g']),
            isTrue,
          );
        },
      );

      test(
        'insert b_',
        () {
          list.insertPreservingSort(b_);
          expect(
            eq(list.map((m) => m.pronounciation).toList(),
                ['b', 'b', 'd', 'f']),
            isTrue,
          );
        },
      );

      test(
        'insert d_',
        () {
          list.insertPreservingSort(d_);
          expect(
            eq(list.map((m) => m.pronounciation).toList(),
                ['b', 'd', 'd', 'f']),
            isTrue,
          );
        },
      );

      test(
        'insert f_',
        () {
          list.insertPreservingSort(f_);
          expect(
            eq(list.map((m) => m.pronounciation).toList(),
                ['b', 'd', 'f', 'f']),
            isTrue,
          );
        },
      );

      test(
        'insert a into listSingleElement',
        () {
          listSingleElement.insertPreservingSort(a);
          expect(
            eq(listSingleElement.map((m) => m.pronounciation).toList(),
                ['a', 'b']),
            isTrue,
          );
        },
      );

      test(
        'insert b_ into listSingleElement',
        () {
          listSingleElement.insertPreservingSort(b_);
          expect(
            eq(listSingleElement.map((m) => m.pronounciation).toList(),
                ['b', 'b']),
            isTrue,
          );
        },
      );

      test(
        'insert c into listSingleElement',
        () {
          listSingleElement.insertPreservingSort(c);
          expect(
            eq(listSingleElement.map((m) => m.pronounciation).toList(),
                ['b', 'c']),
            isTrue,
          );
        },
      );

      test(
        'insert a into listEmpty',
        () {
          listEmpty.insertPreservingSort(a);
          expect(
            eq(listEmpty.map((m) => m.pronounciation).toList(), ['a']),
            isTrue,
          );
        },
      );
    },
  );

  test(
    'Mappings should be sorted using our custom mapping. This does not test words which use letters outside the mapping.',
    () {
      const nonAlphabeticWordsSorted = [
        '!',
        '!!',
        '!*',
        '!+',
        '!-',
        '*',
        '*!',
        '**',
        '*+',
        '*-',
        '+',
        '+!',
        '+*',
        '++',
        '+-',
        '-',
        '-!',
        '-*',
        '-+',
        '--',
      ];

      // This subset of the map contains a representative set of letters:
      // all the a's, including all the accented characters, as well as
      // some non-accented characters such as b and c. For each of these,
      // capital letters are included.
      final smallMap = Map.fromEntries(characterMap.entries.take(20));

      // https://stackoverflow.com/a/56118115/14464173
      int compareGroundTruthStackoverflow(String a, String b) {
        late int charAint;
        late int charBint;
        int min = a.length;
        if (b.length < a.length) min = b.length;
        for (int i = 0; i < min; ++i) {
          String charA = a[i];
          String charB = b[i];
          if (smallMap.containsKey(charA)) {
            charAint = smallMap[charA]!;
          }
          if (smallMap.containsKey(charB)) {
            charBint = smallMap[charB]!;
          }
          if (charAint > charBint) {
            return 1;
          } else if (charAint < charBint) {
            return -1;
          }
        }
        if (a.length < b.length) {
          return -1;
        } else if (a.length > b.length) {
          return 1;
        }
        return 0;
      }

      // The letters available to use.
      final letters = smallMap.keys.toList();

      // This list is populated with all zero-, one- and two-letter words.
      final testWords = <String>[''];
      for (final letter1 in letters) {
        testWords.add(letter1);
        testWords.addAll(letters.map((letter2) => letter1 + letter2));
      }

      // Generate a mapping from each word.
      final testMappings = testWords.map((w) => Mapping(
            source: '',
            translation: [''],
            pronounciation: w,
          ));

      // Ensure our result matches the result of the ground truth sorting function.
      for (final mapping1 in testMappings) {
        for (final mapping2 in testMappings) {
          expect(
            mapping1.compareTo(mapping2).sign,
            equals(compareGroundTruthStackoverflow(
              mapping1.pronounciation,
              mapping2.pronounciation,
            ).sign),
          );
        }
      }

      // Add some words from outside the mapping.
      testWords.addAll(nonAlphabeticWordsSorted);

      // Reverse the mappings, then sort them.
      final reversedMappings = testWords.reversed
          .map((w) => Mapping(
                source: '',
                translation: [''],
                pronounciation: w,
              ))
          .toList();
      reversedMappings.sort();

      // We expect to get back the list of words in sorted order (the order in which the list of words was created).
      expect(
        const ListEquality().equals(
          reversedMappings.map((m) => m.pronounciation).toList(),
          testWords,
        ),
        isTrue,
      );
    },
  );
}
