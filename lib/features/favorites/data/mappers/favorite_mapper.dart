import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/favorites/data/models/favorite_hive_model.dart';
import 'package:pinyinapp/features/favorites/domain/entities/favorite_word.dart';
import 'package:pinyinapp/shared/data/mappers/word_snapshot_mapper.dart';

class FavoriteMapper {
  const FavoriteMapper({this.wordMapper = const WordSnapshotMapper()});

  final WordSnapshotMapper wordMapper;

  FavoriteWord toEntity(FavoriteHiveModel model) => FavoriteWord(
        word: wordMapper.toEntity(model.word),
        createdAt: model.createdAt,
      );

  List<FavoriteWord> toEntityList(Iterable<FavoriteHiveModel> models) =>
      models.map(toEntity).toList(growable: false);

  FavoriteHiveModel fromEntity(WordEntry word, {required DateTime createdAt}) =>
      FavoriteHiveModel(
        word: wordMapper.fromEntity(word),
        createdAt: createdAt,
      );
}
