import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

abstract interface class TranslationProvider {
  String get id;

  bool supports({required Language from, required Language to});

  Future<TranslationDto> translate({
    required String text,
    required Language from,
    required Language to,
  });
}
