import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/features/translation/data/datasources/translation_cache_data_source.dart';
import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';

class HiveTranslationCacheDataSource implements TranslationCacheDataSource {
  const HiveTranslationCacheDataSource(this.box);

  final Box<Map> box;

  @override
  Future<CachedTranslation?> read(TranslationCacheKey key) async {
    try {
      final raw = box.get(key.value);
      if (raw == null) return null;
      return CachedTranslation(
        dto: TranslationDto.fromJson(
          (raw['dto']! as Map).cast<String, Object?>(),
        ),
        storedAt: DateTime.fromMillisecondsSinceEpoch(raw['storedAt']! as int),
      );
    } on Object catch (error) {
      throw CacheException('Falha ao ler o cache de tradução.', cause: error);
    }
  }

  @override
  Future<void> write(TranslationCacheKey key, TranslationDto dto) async {
    try {
      await box.put(key.value, {
        'dto': dto.toJson(),
        'storedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } on Object catch (error) {
      throw CacheException('Falha ao gravar o cache de tradução.',
          cause: error);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await box.clear();
    } on Object catch (error) {
      throw CacheException('Falha ao limpar o cache de tradução.',
          cause: error);
    }
  }
}
