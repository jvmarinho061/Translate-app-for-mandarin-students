/// Idiomas suportados, em vocabulário **de domínio**.
///
/// Deliberadamente usa códigos ISO 639-1, e não os códigos de nenhum
/// fornecedor. A tradução para o dialeto de cada API (`zh` vs `cht` vs
/// `zh-CN`...) é responsabilidade de um *codec* na camada de dados. Sem essa
/// separação, trocar de fornecedor obrigaria a mexer no domínio.
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
