import 'package:pinyinapp/features/dictionary/domain/entities/definition.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';
import 'package:pinyinapp/shared/data/models/word_snapshot_model.dart';

class WordSnapshotMapper {
  const WordSnapshotMapper();

  WordSnapshotModel fromEntity(WordEntry word) => WordSnapshotModel(
        id: word.id,
        simplified: word.simplified,
        pinyinMarked: word.pinyin.marked,
        pinyinNumbered: word.pinyin.numbered,
        pinyinToneless: word.pinyin.toneless,
        definitions: word.definitions
            .map(
              (d) => DefinitionSnapshotModel(
                text: d.text,
                languageCode: d.language.isoCode,
                partOfSpeech: d.partOfSpeech,
              ),
            )
            .toList(growable: false),
        hskLevel: word.hskLevel,
      );

  WordEntry toEntity(WordSnapshotModel model) => WordEntry(
        id: model.id,
        simplified: model.simplified,
        pinyin: Pinyin(
          marked: model.pinyinMarked,
          numbered: model.pinyinNumbered,
          toneless: model.pinyinToneless,
        ),
        definitions: model.definitions
            .map(
              (d) => Definition(
                text: d.text,
                // Idioma desconhecido não invalida a definição salva.
                language:
                    Language.fromIsoCode(d.languageCode) ?? Language.english,
                partOfSpeech: d.partOfSpeech,
              ),
            )
            .toList(growable: false),
        hskLevel: model.hskLevel,
      );
}
