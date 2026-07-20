import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/favorites/domain/entities/favorite_word.dart';

abstract interface class FavoritesRepository {
  Stream<Result<List<FavoriteWord>>> watchAll();

  Stream<Result<bool>> watchIsFavorite(String wordId);

  Future<Result<void>> add(WordEntry word);

  Future<Result<void>> remove(String wordId);
}
