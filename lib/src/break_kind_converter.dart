import 'package:json_annotation/json_annotation.dart';

import 'data_structures.dart';

part 'break_kind_converter.g.dart';

// Have to deal with this for now until records can be serialised natively, see below.
@JsonSerializable()
class BreakKindStore {
  final BreakKinds breakKind;
  final String? chunkTranslation;

  BreakKindStore._allFields({
    required this.breakKind,
    required this.chunkTranslation,
  });

  factory BreakKindStore.fromJson(Map<String, dynamic> json) =>
      _$BreakKindStoreFromJson(json);

  Map<String, dynamic> toJson() => _$BreakKindStoreToJson(this);
}

// This class contains the serialisation logic for the BreakKind type.
class BreakKindConverter extends JsonConverter<BreakKind, BreakKindStore> {
  const BreakKindConverter();

  @override
  BreakKind fromJson(BreakKindStore json) => switch (json.breakKind) {
        BreakKinds.pageBreak =>
          PageBreak(chunkTranslation: json.chunkTranslation!),
        BreakKinds.chunkBreak =>
          ChunkBreak(chunkTranslation: json.chunkTranslation!),
        BreakKinds.lineBreak => LineBreak(),
        BreakKinds.noBreak => NoBreak(),
      };

  @override
  BreakKindStore toJson(BreakKind object) => switch (object) {
        // Due to the type hierarchy we must match the subtype first, then the supertype.
        PageBreak(chunkTranslation: final translation) =>
          BreakKindStore._allFields(
            breakKind: BreakKinds.pageBreak,
            chunkTranslation: translation,
          ),
        ChunkBreak(chunkTranslation: final translation) =>
          BreakKindStore._allFields(
            breakKind: BreakKinds.chunkBreak,
            chunkTranslation: translation,
          ),
        LineBreak() => BreakKindStore._allFields(
            breakKind: BreakKinds.lineBreak,
            chunkTranslation: null,
          ),
        NoBreak() => BreakKindStore._allFields(
            breakKind: BreakKinds.noBreak,
            chunkTranslation: null,
          ),
      };
}

// TODO: wait for https://github.com/google/json_serializable.dart/issues/1327 to be implemented and use the following code instead
/*
// This class contains the serialisation logic for the BreakKind type.
class BreakKindConverter extends JsonConverter<BreakKind,
    ({BreakKinds breakKind, String? chunkTranslation})> {
  const BreakKindConverter();

  @override
  BreakKind fromJson(({BreakKinds breakKind, String? chunkTranslation}) json) =>
      switch (json.breakKind) {
        BreakKinds.pageBreak =>
          PageBreak(chunkTranslation: json.chunkTranslation!),
        BreakKinds.chunkBreak =>
          ChunkBreak(chunkTranslation: json.chunkTranslation!),
        BreakKinds.lineBreak => LineBreak(),
        BreakKinds.noBreak => NoBreak(),
      };

  @override
  ({BreakKinds breakKind, String? chunkTranslation}) toJson(BreakKind object) =>
      switch (object) {
        // Due to the type hierarchy we must match the subtype first, then the supertype.
        PageBreak(chunkTranslation: final translation) => (
            breakKind: BreakKinds.pageBreak,
            chunkTranslation: translation,
          ),
        ChunkBreak(chunkTranslation: final translation) => (
            breakKind: BreakKinds.chunkBreak,
            chunkTranslation: translation,
          ),
        LineBreak() => (
            breakKind: BreakKinds.lineBreak,
            chunkTranslation: null,
          ),
        NoBreak() => (
            breakKind: BreakKinds.noBreak,
            chunkTranslation: null,
          ),
      };
}
*/
