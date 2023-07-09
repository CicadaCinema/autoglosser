// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'break_kind_converter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BreakKindStore _$BreakKindStoreFromJson(Map<String, dynamic> json) =>
    BreakKindStore._allFields(
      breakKind: $enumDecode(_$BreakKindsEnumMap, json['breakKind']),
      chunkTranslation: json['chunkTranslation'] as String?,
    );

Map<String, dynamic> _$BreakKindStoreToJson(BreakKindStore instance) =>
    <String, dynamic>{
      'breakKind': _$BreakKindsEnumMap[instance.breakKind]!,
      'chunkTranslation': instance.chunkTranslation,
    };

const _$BreakKindsEnumMap = {
  BreakKinds.noBreak: 'noBreak',
  BreakKinds.lineBreak: 'lineBreak',
  BreakKinds.chunkBreak: 'chunkBreak',
  BreakKinds.pageBreak: 'pageBreak',
};
