import 'package:pinyinapp/features/dictionary/data/dtos/word_entry_dto.dart';

abstract interface class LocalDictionaryDataSource {
  Future<List<WordEntryDto>> search({
    required String query,
    required int limit,
    required int offset,
  });
  Future<WordEntryDto?> findById(String id);
}
