import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/core/result/result_stream.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/history/data/datasources/history_local_data_source.dart';
import 'package:pinyinapp/features/history/data/mappers/history_mapper.dart';
import 'package:pinyinapp/features/history/domain/entities/history_entry.dart';
import 'package:pinyinapp/features/history/domain/history_policy.dart';
import 'package:pinyinapp/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl({
    required this.dataSource,
    this.mapper = const HistoryMapper(),
    this.maxEntries = HistoryPolicy.maxEntries,
  });

  final HistoryLocalDataSource dataSource;
  final HistoryMapper mapper;
  final int maxEntries;

  @override
  Stream<Result<List<HistoryEntry>>> watchAll({int? limit}) =>
      dataSource.watchAll(limit: limit).toResult(
            onData: mapper.toEntityList,
            onError: (error) => DatabaseFailure(debugMessage: error.toString()),
          );

  @override
  Future<Result<void>> record(WordEntry word) async {
    try {
      final existing = dataSource.read(word.id);
      await dataSource.put(
        mapper.fromEntity(
          word,
          lastVisitedAt: DateTime.now(),
          visitCount: (existing?.visitCount ?? 0) + 1,
        ),
      );
      await dataSource.trimTo(maxEntries);
      return const Success(null);
    } on Object catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.toString()));
    }
  }

  @override
  Future<Result<void>> remove(String wordId) async {
    try {
      await dataSource.delete(wordId);
      return const Success(null);
    } on Object catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.toString()));
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await dataSource.clear();
      return const Success(null);
    } on Object catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.toString()));
    }
  }
}
