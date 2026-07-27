import 'package:pinyinapp/features/translation/domain/entities/language.dart';

/// Converte o vocabulário de domínio para os códigos do Google.
class GoogleLanguageCodec {
  const GoogleLanguageCodec();

  static const Map<Language, String> _codes = {
    Language.chinese: 'zh',
    Language.portuguese: 'pt',
    Language.english: 'en',
  };

  String encode(Language language) => _codes[language]!;

  // O Google pode devolver 'zh-CN' em detectedSourceLanguage.
  Language? decode(String code) => switch (code) {
        'zh' || 'zh-CN' || 'zh-TW' => Language.chinese,
        'pt' => Language.portuguese,
        'en' => Language.english,
        _ => null,
      };

  bool supports(Language language) => _codes.containsKey(language);
}
