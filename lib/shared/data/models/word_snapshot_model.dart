class WordSnapshotModel {
  const WordSnapshotModel({
    required this.id,
    required this.simplified,
    required this.pinyinMarked,
    required this.pinyinNumbered,
    required this.pinyinToneless,
    required this.definitions,
    this.hskLevel,
  });

  static const int schemaVersion = 1;

  final String id;
  final String simplified;
  final String pinyinMarked;
  final String pinyinNumbered;
  final String pinyinToneless;
  final List<DefinitionSnapshotModel> definitions;
  final int? hskLevel;

  Map<String, Object?> toMap() => {
        'schemaVersion': schemaVersion,
        'id': id,
        'simplified': simplified,
        'pinyinMarked': pinyinMarked,
        'pinyinNumbered': pinyinNumbered,
        'pinyinToneless': pinyinToneless,
        'definitions': definitions.map((d) => d.toMap()).toList(),
        'hskLevel': hskLevel,
      };

  factory WordSnapshotModel.fromMap(Map<dynamic, dynamic> map) =>
      WordSnapshotModel(
        id: map['id']! as String,
        simplified: map['simplified']! as String,
        pinyinMarked: map['pinyinMarked']! as String,
        pinyinNumbered: map['pinyinNumbered']! as String,
        pinyinToneless: map['pinyinToneless']! as String,
        definitions: (map['definitions'] as List? ?? const [])
            .cast<Map<dynamic, dynamic>>()
            .map(DefinitionSnapshotModel.fromMap)
            .toList(growable: false),
        hskLevel: map['hskLevel'] as int?,
      );
}

class DefinitionSnapshotModel {
  const DefinitionSnapshotModel({
    required this.text,
    required this.languageCode,
    this.partOfSpeech,
  });

  final String text;
  final String languageCode;
  final String? partOfSpeech;

  Map<String, Object?> toMap() => {
        'text': text,
        'languageCode': languageCode,
        'partOfSpeech': partOfSpeech,
      };

  factory DefinitionSnapshotModel.fromMap(Map<dynamic, dynamic> map) =>
      DefinitionSnapshotModel(
        text: map['text']! as String,
        languageCode: map['languageCode']! as String,
        partOfSpeech: map['partOfSpeech'] as String?,
      );
}
