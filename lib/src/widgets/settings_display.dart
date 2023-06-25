import 'package:flutter/material.dart';

import '../data_structures.dart';

class SettingsDisplay extends StatefulWidget {
  const SettingsDisplay({super.key, required this.globalSettings});

  final GlobalSettings globalSettings;

  @override
  State<SettingsDisplay> createState() => _SettingsDisplayState();
}

class _SettingsDisplayState extends State<SettingsDisplay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          DropdownButton<SourceLanguage>(
              value: widget.globalSettings.sourceLanguage,
              onChanged: (SourceLanguage? newValue) {
                setState(() {
                  widget.globalSettings.sourceLanguage = newValue!;
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
