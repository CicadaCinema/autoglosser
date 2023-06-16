import 'package:autoglosser/src/widgets/text_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/data_structures.dart';
import 'src/widgets/map_display.dart';

final sampleText = FullText.fromString('''知天之所為，知人之所為者，至矣。
知天之所為者，天而生也；知人之所為者，以其知之所知，以養其知之所不知，終其天年而不中道夭者，是知之盛也。
雖然，有患。夫知有所待而後當，其所待者特未定也。
庸詎知吾所謂天之非人乎？所謂人之非天乎？且有真人，而後有真知。''');

final sampleMapping = FullMap(mappingSections: {
  'Default': [
    Mapping(pronounciation: 'aa', source: '老', translation: ['cheese']),
    Mapping(pronounciation: 'bb', source: '子', translation: ['eggs']),
    Mapping(pronounciation: 'bbd', source: '窈', translation: ['salmon']),
    Mapping(
        pronounciation: 'aada',
        source: '聲',
        translation: ['hamburger', 'pizza']),
  ],
  'Extra': [
    Mapping(pronounciation: 'basdb', source: '生', translation: ['sadeggs']),
    Mapping(pronounciation: 'fsdbbd', source: '生', translation: ['sadmon']),
  ],
});

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Translation'),
                Tab(text: 'Map'),
              ],
            ),
            // Do not show app bar, only show tabs.
            toolbarHeight: 0,
          ),
          body: TabBarView(
            children: [
              TextDisplay(text: sampleText),
              MapDisplay(map: sampleMapping)
            ],
          ),
        ),
      ),
    );
  }
}
