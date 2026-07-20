import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/history/domain/entities/history_entry.dart';

abstract interface class HistoryRepository {
  Stream<Result<List<HistoryEntry>>> watchAll({int? limit});

  Future<Result<void>> record(WordEntry word);

  Future<Result<void>> remove(String wordId);

  Future<Result<void>> clear();
}
