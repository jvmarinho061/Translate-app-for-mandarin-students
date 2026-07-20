import 'package:pinyinapp/features/dictionary/data/dtos/word_entry_dto.dart';
abstract interface class DictionaryDataProvider {
  String get id;

  Future<WordEntryDto?> fetchEntry(String term);
}
