import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data_structures/data_structures.dart';

class SettingsDisplay extends ConsumerStatefulWidget {
  const SettingsDisplay({super.key});

  @override
  ConsumerState<SettingsDisplay> createState() => _SettingsDisplayState();
}

class _SettingsDisplayState extends ConsumerState<SettingsDisplay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          DropdownButton<SourceLanguage>(
              value: ref.watch(selectedLanguageProvider),
              onChanged: (SourceLanguage? newValue) {
                setState(() {
                  ref.read(selectedLanguageProvider.notifier).set(newValue!);
                });
              },
              items: SourceLanguage.values.map((SourceLanguage classType) {
                return DropdownMenuItem<SourceLanguage>(
                    value: classType, child: Text(classType.toString()));
              }).toList())
        ],
      ),
    );
  }
}
