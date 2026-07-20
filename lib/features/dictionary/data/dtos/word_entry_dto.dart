import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_schema.dart';

class WordEntryDto {
  const WordEntryDto({
    required this.id,
    required this.simplified,
    required this.pinyinNumbered,
    required this.pinyinMarked,
    required this.pinyinToneless,
    required this.definitions,
    this.hskLevel,
  });

  final String id;
  final String simplified;

  /// Forma nativa do CC-CEDICT: `ni3 hao3`.
  final String pinyinNumbered;

  /// Formas derivadas, pré-calculadas em build-time.
  final String pinyinMarked;
  final String pinyinToneless;

  final List<String> definitions;
  final int? hskLevel;

  factory WordEntryDto.fromMap(Map<String, Object?> map) => WordEntryDto(
        id: map[DictionarySchema.id]!.toString(),
        simplified: map[DictionarySchema.simplified]! as String,
        pinyinNumbered: map[DictionarySchema.pinyinNumbered]! as String,
        pinyinMarked: map[DictionarySchema.pinyinMarked]! as String,
        pinyinToneless: map[DictionarySchema.pinyinToneless]! as String,
        definitions: _splitDefinitions(map[DictionarySchema.definitions]),
        hskLevel: map[DictionarySchema.hskLevel] as int?,
      );

  // O CC-CEDICT separa acepções por '/'.
  static List<String> _splitDefinitions(Object? raw) =>
      (raw as String? ?? '')
          .split('/')
          .map((d) => d.trim())
          .where((d) => d.isNotEmpty)
          .toList(growable: false);
}
