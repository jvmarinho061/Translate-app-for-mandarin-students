import 'package:pinyinapp/features/translation/domain/entities/language.dart';

/// Converte o vocabulário de domínio para os códigos da Baidu.
class BaiduLanguageCodec {
  const BaiduLanguageCodec();

  static const Map<Language, String> _codes = {
    Language.chinese: 'zh',
    Language.portuguese: 'pt',
    Language.english: 'en',
  };

  String encode(Language language) => _codes[language]!;

  Language? decode(String code) => switch (code) {
        'zh' || 'cht' => Language.chinese,
        'pt' => Language.portuguese,
        'en' => Language.english,
        _ => null,
      };

  bool supports(Language language) => _codes.containsKey(language);
}
