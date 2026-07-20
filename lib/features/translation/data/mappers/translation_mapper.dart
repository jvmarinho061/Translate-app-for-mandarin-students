import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';
import 'package:pinyinapp/features/translation/domain/entities/translation.dart';
class TranslationMapper {
  const TranslationMapper();

  Translation toEntity(
    TranslationDto dto, {
    required DateTime retrievedAt,
    bool isStale = false,
  }) {
    final from = Language.fromIsoCode(dto.fromIsoCode);
    final to = Language.fromIsoCode(dto.toIsoCode);

    if (from == null || to == null) {
      throw ApiContractException(
        'Idioma desconhecido no DTO: ${dto.fromIsoCode} -> ${dto.toIsoCode}',
      );
    }

    return Translation(
      sourceText: dto.sourceText,
      translatedText: dto.translatedText,
      from: from,
      to: to,
      retrievedAt: retrievedAt,
      isStale: isStale,
    );
  }
}
