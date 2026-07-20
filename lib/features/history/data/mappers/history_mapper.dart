import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/history/data/models/history_hive_model.dart';
import 'package:pinyinapp/features/history/domain/entities/history_entry.dart';
import 'package:pinyinapp/shared/data/mappers/word_snapshot_mapper.dart';

class HistoryMapper {
  const HistoryMapper({this.wordMapper = const WordSnapshotMapper()});

  final WordSnapshotMapper wordMapper;

  HistoryEntry toEntity(HistoryHiveModel model) => HistoryEntry(
        word: wordMapper.toEntity(model.word),
        lastVisitedAt: model.lastVisitedAt,
        visitCount: model.visitCount,
      );

  List<HistoryEntry> toEntityList(Iterable<HistoryHiveModel> models) =>
      models.map(toEntity).toList(growable: false);

  HistoryHiveModel fromEntity(
    WordEntry word, {
    required DateTime lastVisitedAt,
    required int visitCount,
  }) =>
      HistoryHiveModel(
        word: wordMapper.fromEntity(word),
        lastVisitedAt: lastVisitedAt,
        visitCount: visitCount,
      );
}
