import 'package:json_annotation/json_annotation.dart';

import 'data_structures/data_structures.dart';

// This class contains the serialisation logic for the BreakKind type.
class BreakKindConverter
    extends JsonConverter<BreakKind, Map<String, dynamic>> {
  const BreakKindConverter();

  @override
  BreakKind fromJson(Map<String, dynamic> json) {
    return switch (BreakKinds.values
        .firstWhere((e) => e.toString() == json['breakKind'])) {
      BreakKinds.pageBreak =>
        PageBreak(chunkTranslation: json['chunkTranslation']!),
      BreakKinds.chunkBreak =>
        ChunkBreak(chunkTranslation: json['chunkTranslation']!),
      BreakKinds.lineBreak => LineBreak(),
      BreakKinds.noBreak => NoBreak(),
    };
  }

  @override
  Map<String, dynamic> toJson(BreakKind object) => switch (object) {
        // Due to the type hierarchy we must match the subtype first, then the supertype.
        PageBreak(chunkTranslation: final translation) => {
            'breakKind': BreakKinds.pageBreak.toString(),
            'chunkTranslation': translation,
          },
        ChunkBreak(chunkTranslation: final translation) => {
            'breakKind': BreakKinds.chunkBreak.toString(),
            'chunkTranslation': translation,
          },
        LineBreak() => {
            'breakKind': BreakKinds.lineBreak.toString(),
            'chunkTranslation': null,
          },
        NoBreak() => {
            'breakKind': BreakKinds.noBreak.toString(),
            'chunkTranslation': null,
          },
      };
}
