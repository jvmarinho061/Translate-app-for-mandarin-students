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
        traditional:
            dto.traditional == dto.simplified ? null : dto.traditional,
        pinyin: Pinyin(
          marked: dto.pinyinMarked ?? dto.pinyinNumbered,
          numbered: dto.pinyinNumbered,
          toneless: dto.pinyinToneless ?? _stripTones(dto.pinyinNumbered),
        ),
        definitions: dto.definitions
            .map(
              (text) => Definition(text: text, language: Language.english),
            )
            .toList(growable: false),
        hskLevel: dto.hskLevel,
      );

  List<WordEntry> toEntityList(Iterable<WordEntryDto> dtos) =>
      dtos.map(toEntity).toList(growable: false);

  /// Fallback para quando a forma sem tom não veio pré-calculada.
  String _stripTones(String numbered) =>
      numbered.replaceAll(RegExp(r'[1-5]'), '').toLowerCase();
}
