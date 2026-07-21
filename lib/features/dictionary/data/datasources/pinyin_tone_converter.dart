abstract final class PinyinToneConverter {
  static const Map<String, List<String>> _vowels = {
    'a': ['ā', 'á', 'ǎ', 'à', 'a'],
    'e': ['ē', 'é', 'ě', 'è', 'e'],
    'i': ['ī', 'í', 'ǐ', 'ì', 'i'],
    'o': ['ō', 'ó', 'ǒ', 'ò', 'o'],
    'u': ['ū', 'ú', 'ǔ', 'ù', 'u'],
    'ü': ['ǖ', 'ǘ', 'ǚ', 'ǜ', 'ü'],
  };

  static String convert(String numbered) => numbered
      .split(RegExp(r'\s+'))
      .where((syllable) => syllable.isNotEmpty)
      .map(convertSyllable)
      .join(' ');

  static String convertSyllable(String syllable) {
    final match = RegExp(r'([a-zA-Zü:]+)([1-5])$').firstMatch(syllable);
    if (match == null) return syllable.replaceAll('u:', 'ü');

    final letters = match.group(1)!.replaceAll('u:', 'ü').toLowerCase();
    final tone = int.parse(match.group(2)!);
    if (tone == 5) return letters;

    final index = _markIndex(letters);
    if (index == -1) return letters;

    final marked = _vowels[letters[index]]![tone - 1];
    return letters.replaceRange(index, index + 1, marked);
  }

  static int _markIndex(String letters) {
    final a = letters.indexOf('a');
    if (a != -1) return a;
    final e = letters.indexOf('e');
    if (e != -1) return e;
    final ou = letters.indexOf('ou');
    if (ou != -1) return ou;

    for (var i = letters.length - 1; i >= 0; i--) {
      if (_vowels.containsKey(letters[i])) return i;
    }
    return -1;
  }
}
