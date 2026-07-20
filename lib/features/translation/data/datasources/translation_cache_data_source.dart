import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';

class TranslationCacheKey {
  const TranslationCacheKey({
    required this.text,
    required this.fromIsoCode,
    required this.toIsoCode,
  });

  final String text;
  final String fromIsoCode;
  final String toIsoCode;

  String get value => '$fromIsoCode|$toIsoCode|$text';

  @override
  bool operator ==(Object other) =>
      other is TranslationCacheKey && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class CachedTranslation {
  const CachedTranslation({required this.dto, required this.storedAt});

  final TranslationDto dto;
  final DateTime storedAt;
}

abstract interface class TranslationCacheDataSource {
  Future<CachedTranslation?> read(TranslationCacheKey key);

  Future<void> write(TranslationCacheKey key, TranslationDto dto);

  Future<void> clear();
}

class InMemoryTranslationCacheDataSource implements TranslationCacheDataSource {
  InMemoryTranslationCacheDataSource({this.maxEntries = 200});

  final int maxEntries;
  final Map<String, CachedTranslation> _entries = <String, CachedTranslation>{};

  @override
  Future<CachedTranslation?> read(TranslationCacheKey key) async {
    final cached = _entries.remove(key.value);
    if (cached == null) return null;
    _entries[key.value] = cached;
    return cached;
  }

  @override
  Future<void> write(TranslationCacheKey key, TranslationDto dto) async {
    _entries.remove(key.value);
    _entries[key.value] = CachedTranslation(dto: dto, storedAt: DateTime.now());
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  @override
  Future<void> clear() async => _entries.clear();
}
