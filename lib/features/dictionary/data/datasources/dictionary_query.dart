abstract final class DictionaryQuery {
  static final RegExp _han = RegExp(r'[一-鿿]');
  static final RegExp _toneDigits = RegExp('[1-5]');
  static final RegExp _whitespace = RegExp(r'\s+');

  static const Map<String, String> _diacritics = {
    'ā': 'a', 'á': 'a', 'ǎ': 'a', 'à': 'a',
    'ē': 'e', 'é': 'e', 'ě': 'e', 'è': 'e',
    'ī': 'i', 'í': 'i', 'ǐ': 'i', 'ì': 'i',
    'ō': 'o', 'ó': 'o', 'ǒ': 'o', 'ò': 'o',
    'ū': 'u', 'ú': 'u', 'ǔ': 'u', 'ù': 'u',
    'ǖ': 'v', 'ǘ': 'v', 'ǚ': 'v', 'ǜ': 'v', 'ü': 'v',
  };

  static bool containsHan(String input) => _han.hasMatch(input);
  static String normalizePinyin(String input) {
    final buffer = StringBuffer();
    // "u:" é a notação do CC-CEDICT para ü.
    for (final char in input.toLowerCase().replaceAll('u:', 'v').split('')) {
      buffer.write(_diacritics[char] ?? char);
    }
    return buffer
        .toString()
        .replaceAll(_toneDigits, '')
        .replaceAll(_whitespace, ' ')
        .trim();
  }

  static String escapeLike(String input) => input
      .replaceAll('\\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');
}
