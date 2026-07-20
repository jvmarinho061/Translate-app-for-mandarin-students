
enum Language {
  chinese('zh'),
  portuguese('pt'),
  english('en');

  const Language(this.isoCode);

  final String isoCode;

  static Language? fromIsoCode(String code) {
    for (final language in Language.values) {
      if (language.isoCode == code.toLowerCase()) return language;
    }
    return null;
  }
}
