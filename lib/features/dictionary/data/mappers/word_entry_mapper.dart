import 'package:pinyinapp/features/dictionary/data/dtos/word_entry_dto.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/definition.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

class WordEntryMapper {
  const WordEntryMapper();

  WordEntry toEntity(WordEntryDto dto) => WordEntry(
        id: dto.id,
        simplified: dto.simplified,
        pinyin: Pinyin(
          marked: dto.pinyinMarked,
          numbered: dto.pinyinNumbered,
          toneless: dto.pinyinToneless,
        ),
        // O CC-CEDICT é chinês-inglês; marcar o idioma impede que a UI
        // apresente conteúdo EN como se fosse PT.
        definitions: dto.definitions
            .map((text) => Definition(text: text, language: Language.english))
            .toList(growable: false),
        hskLevel: dto.hskLevel,
      );

  List<WordEntry> toEntityList(Iterable<WordEntryDto> dtos) =>
      dtos.map(toEntity).toList(growable: false);
}
