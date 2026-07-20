class WordEntryDto {
  const WordEntryDto({
    required this.id,
    required this.simplified,
    required this.pinyinNumbered,
    required this.definitions,
    this.traditional,
    this.pinyinMarked,
    this.pinyinToneless,
    this.hskLevel,
  });

  final String id;
  final String simplified;
  final String? traditional;

  final String pinyinNumbered;

  final String? pinyinMarked;
  final String? pinyinToneless;

  final List<String> definitions;
  final int? hskLevel;

  factory WordEntryDto.fromMap(Map<String, Object?> map) => WordEntryDto(
        id: map['id']!.toString(),
        simplified: map['simplified']! as String,
        traditional: map['traditional'] as String?,
        pinyinNumbered: map['pinyin_numbered']! as String,
        pinyinMarked: map['pinyin_marked'] as String?,
        pinyinToneless: map['pinyin_toneless'] as String?,
        definitions: (map['definitions'] as String? ?? '')
            .split('/')
            .map((d) => d.trim())
            .where((d) => d.isNotEmpty)
            .toList(growable: false),
        hskLevel: map['hsk_level'] as int?,
      );
}
