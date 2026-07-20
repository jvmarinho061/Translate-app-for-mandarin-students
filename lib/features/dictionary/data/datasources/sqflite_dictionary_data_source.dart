import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_query.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/dictionary_schema.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/local_dictionary_data_source.dart';
import 'package:pinyinapp/features/dictionary/data/dtos/word_entry_dto.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
class SqfliteDictionaryDataSource implements LocalDictionaryDataSource {
  SqfliteDictionaryDataSource(this.openDatabase);

  final Future<Database> Function() openDatabase;

  Future<Database>? _pending;

  Future<Database> _db() => _pending ??= openDatabase();

  @override
  Future<List<WordEntryDto>> search({
    required String query,
    required int limit,
    required int offset,
  }) async {
    final isHan = DictionaryQuery.containsHan(query);
    final term = isHan
        ? query.trim()
        : DictionaryQuery.normalizePinyin(query);

    if (term.isEmpty) return const [];

    final column =
        isHan ? DictionarySchema.simplified : DictionarySchema.pinyinToneless;

    try {
      final db = await _db();
      final rows = await db.rawQuery(
        '''
SELECT * FROM ${DictionarySchema.table}
WHERE $column LIKE ? ESCAPE '\\'
ORDER BY ($column = ?) DESC, LENGTH(${DictionarySchema.simplified}), $column
LIMIT ? OFFSET ?''',
        ['${DictionaryQuery.escapeLike(term)}%', term, limit, offset],
      );
      return rows.map(WordEntryDto.fromMap).toList(growable: false);
    } on Object catch (error) {
      throw DatabaseException('Falha ao buscar "$query".', cause: error);
    }
  }

  @override
  Future<WordEntryDto?> findById(String id) async {
    try {
      final db = await _db();
      final rows = await db.query(
        DictionarySchema.table,
        where: '${DictionarySchema.id} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return WordEntryDto.fromMap(rows.first);
    } on Object catch (error) {
      throw DatabaseException('Falha ao ler a entrada $id.', cause: error);
    }
  }
}
