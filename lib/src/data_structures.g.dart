// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_structures.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word._allFields(
      source: json['source'] as String,
      pronounciation: json['pronounciation'] as String,
      gloss: json['gloss'] as String,
      breakKind: const BreakKindConverter()
          .fromJson(json['breakKind'] as BreakKindStore),
    );

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'source': instance.source,
      'pronounciation': instance.pronounciation,
      'gloss': instance.gloss,
      'breakKind': const BreakKindConverter().toJson(instance.breakKind),
    };

FullText _$FullTextFromJson(Map<String, dynamic> json) => FullText._allFields(
      allWords: const LinkedListWordConverter()
          .fromJson(json['allWords'] as List<Map<String, dynamic>>),
    );

Map<String, dynamic> _$FullTextToJson(FullText instance) => <String, dynamic>{
      'allWords': const LinkedListWordConverter().toJson(instance.allWords),
    };

Mapping _$MappingFromJson(Map<String, dynamic> json) => Mapping._allFields(
      pronounciation: json['pronounciation'] as String,
      source: json['source'] as String,
      translation: (json['translation'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MappingToJson(Mapping instance) => <String, dynamic>{
      'pronounciation': instance.pronounciation,
      'source': instance.source,
      'translation': instance.translation,
    };

FullMap _$FullMapFromJson(Map<String, dynamic> json) => FullMap._allFields(
      (json['_sourceToMappings'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as List<dynamic>)
                .map((e) => Mapping.fromJson(e as Map<String, dynamic>))
                .toList()),
      ),
      mappingSections: (json['mappingSections'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            const LinkedListMappingConverter()
                .fromJson(e as List<Map<String, dynamic>>)),
      ),
    );

Map<String, dynamic> _$FullMapToJson(FullMap instance) => <String, dynamic>{
      'mappingSections': instance.mappingSections.map(
          (k, e) => MapEntry(k, const LinkedListMappingConverter().toJson(e))),
      '_sourceToMappings': instance._sourceToMappings
          .map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
    };
