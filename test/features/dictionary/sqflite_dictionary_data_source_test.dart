import 'package:flutter_test/flutter_test.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_schema.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/sqflite_dictionary_data_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> _seededDatabase() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(singleInstance: false),
  );
  await db.execute(DictionarySchema.createTable);
  for (final statement in DictionarySchema.createIndexes) {
    await db.execute(statement);
  }

  const rows = [
    (1, '你好', 'ni3 hao3', 'nǐ hǎo', 'ni hao', '/hello/hi/'),
    (2, '你', 'ni3', 'nǐ', 'ni', '/you/'),
    (3, '你们', 'ni3 men5', 'nǐ men', 'ni men', '/you (plural)/'),
    (4, '好', 'hao3', 'hǎo', 'hao', '/good/well/'),
    (5, '中国', 'zhong1 guo2', 'zhōng guó', 'zhong guo', '/China/'),
  ];

  for (final (id, simplified, numbered, marked, toneless, defs) in rows) {
    await db.insert(DictionarySchema.table, {
      DictionarySchema.id: id,
      DictionarySchema.simplified: simplified,
      DictionarySchema.pinyinNumbered: numbered,
      DictionarySchema.pinyinMarked: marked,
      DictionarySchema.pinyinToneless: toneless,
      DictionarySchema.definitions: defs,
    });
  }
  return db;
}

void main() {
  setUpAll(sqfliteFfiInit);

  late SqfliteDictionaryDataSource dataSource;

  setUp(() => dataSource = SqfliteDictionaryDataSource(_seededDatabase));

  Future<List<String>> search(String query) async {
    final results =
        await dataSource.search(query: query, limit: 20, offset: 0);
    return results.map((e) => e.simplified).toList();
  }

  test('busca por hanzi com prefixo', () async {
    final results = await search('你');
    expect(results.first, '你');
    expect(results, containsAll(['你好', '你们']));
    expect(results, hasLength(3));
  });

  test('busca por pinyin sem tom', () async {
    expect(await search('ni hao'), ['你好']);
  });

  test('busca por pinyin com marcas de tom é normalizada', () async {
    expect(await search('nǐ hǎo'), ['你好']);
  });

  test('busca por pinyin com dígitos de tom é normalizada', () async {
    expect(await search('ni3 hao3'), ['你好']);
  });

  test('correspondência exata vem primeiro', () async {
    expect((await search('ni')).first, '你');
  });

  test('curinga do LIKE digitado não retorna o dicionário inteiro', () async {
    expect(await search('%'), isEmpty);
  });

  test('query vazia não consulta o banco', () async {
    expect(await search('   '), isEmpty);
  });

  test('findById devolve a entrada; id ausente devolve null', () async {
    expect((await dataSource.findById('1'))?.simplified, '你好');
    expect(await dataSource.findById('999'), isNull);
  });

  test('definições são divididas por /', () async {
    final entry = await dataSource.findById('1');
    expect(entry?.definitions, ['hello', 'hi']);
  });
}
