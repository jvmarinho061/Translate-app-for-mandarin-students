abstract final class DictionarySchema {
  static const String table = 'entries';

  static const String id = 'id';
  static const String simplified = 'simplified';
  static const String pinyinNumbered = 'pinyin_numbered';
  static const String pinyinMarked = 'pinyin_marked';
  static const String pinyinToneless = 'pinyin_toneless';
  static const String definitions = 'definitions';
  static const String hskLevel = 'hsk_level';

  static const int version = 1;

  static const String createTable = '''
CREATE TABLE IF NOT EXISTS $table (
  $id INTEGER PRIMARY KEY,
  $simplified TEXT NOT NULL,
  $pinyinNumbered TEXT NOT NULL,
  $pinyinMarked TEXT NOT NULL,
  $pinyinToneless TEXT NOT NULL,
  $definitions TEXT NOT NULL,
  $hskLevel INTEGER
)''';

  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_${table}_$simplified '
        'ON $table($simplified)',
    'CREATE INDEX IF NOT EXISTS idx_${table}_$pinyinToneless '
        'ON $table($pinyinToneless)',
  ];
}
