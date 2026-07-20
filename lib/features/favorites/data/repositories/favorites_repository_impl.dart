import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/core/result/result_stream.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:pinyinapp/features/favorites/data/mappers/favorite_mapper.dart';
import 'package:pinyinapp/features/favorites/domain/entities/favorite_word.dart';
import 'package:pinyinapp/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl({
    required this.dataSource,
    this.mapper = const FavoriteMapper(),
  });

  final FavoritesLocalDataSource dataSource;
  final FavoriteMapper mapper;

  @override
  Stream<Result<List<FavoriteWord>>> watchAll() => dataSource.watchAll().toResult(
        onData: mapper.toEntityList,
        onError: (error) => DatabaseFailure(debugMessage: error.toString()),
      );

  @override
  Stream<Result<bool>> watchIsFavorite(String wordId) =>
      dataSource.watchContains(wordId).toResult(
            onData: (isFavorite) => isFavorite,
            onError: (error) => DatabaseFailure(debugMessage: error.toString()),
          );

  @override
  Future<Result<void>> add(WordEntry word) async {
    try {
      if (dataSource.contains(word.id)) return const Success(null);
      await dataSource.put(mapper.fromEntity(word, createdAt: DateTime.now()));
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
}
