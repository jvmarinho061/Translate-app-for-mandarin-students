import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/data/datasources/local_dictionary_data_source.dart';
import 'package:pinyinapp/features/dictionary/data/mappers/word_entry_mapper.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/dictionary/domain/repositories/dictionary_repository.dart';

class DictionaryRepositoryImpl implements DictionaryRepository {
  const DictionaryRepositoryImpl({
    required this.localDataSource,
    this.mapper = const WordEntryMapper(),
  });

  final LocalDictionaryDataSource localDataSource;
  final WordEntryMapper mapper;

  @override
  Future<Result<List<WordEntry>>> search({
    required String query,
    int limit = 30,
    int offset = 0,
  }) async {
    final normalized = query.trim();
    // Query vazia não toca o banco.
    if (normalized.isEmpty) return const Success(<WordEntry>[]);

    try {
      final dtos = await localDataSource.search(
        query: normalized,
        limit: limit,
        offset: offset,
      );
      return Success(mapper.toEntityList(dtos));
    } on DatabaseException catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.message));
    } on Object catch (error) {
      return FailureResult(UnexpectedFailure(debugMessage: error.toString()));
    }
  }

  @override
  Future<Result<WordEntry>> getById(String id) async {
    try {
      final dto = await localDataSource.findById(id);
      if (dto == null) {
        return FailureResult(NotFoundFailure(debugMessage: 'id=$id'));
      }
      return Success(mapper.toEntity(dto));
    } on DatabaseException catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.message));
    } on Object catch (error) {
      return FailureResult(UnexpectedFailure(debugMessage: error.toString()));
    }
  }
}
