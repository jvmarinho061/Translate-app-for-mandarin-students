import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/features/translation/data/datasources/hive_translation_cache_data_source.dart';
import 'package:pinyinapp/features/translation/data/datasources/translation_cache_data_source.dart';
import 'package:pinyinapp/features/translation/data/dtos/translation_dto.dart';

const _key = TranslationCacheKey(
  text: '你好',
  fromIsoCode: 'zh',
  toIsoCode: 'pt',
);

const _dto = TranslationDto(
  sourceText: '你好',
  translatedText: 'Olá',
  fromIsoCode: 'zh',
  toIsoCode: 'pt',
  providerId: 'google',
);

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cache_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async => tempDir.delete(recursive: true));

  test('grava e lê uma tradução', () async {
    final box = await Hive.openBox<Map>('cache_rw');
    final cache = HiveTranslationCacheDataSource(box);

    await cache.write(_key, _dto);
    final cached = await cache.read(_key);

    expect(cached?.dto.translatedText, 'Olá');
    expect(cached?.dto.providerId, 'google');
    await box.close();
  });

  test('chave ausente devolve null', () async {
    final box = await Hive.openBox<Map>('cache_missing');
    final cache = HiveTranslationCacheDataSource(box);

    expect(await cache.read(_key), isNull);
    await box.close();
  });

  test('sobrevive ao fechamento e reabertura da box', () async {
    final box = await Hive.openBox<Map>('cache_persist');
    await HiveTranslationCacheDataSource(box).write(_key, _dto);
    await box.close();

    // É exatamente isto que o cache em memória não fazia.
    final reopened = await Hive.openBox<Map>('cache_persist');
    final cached = await HiveTranslationCacheDataSource(reopened).read(_key);

    expect(cached?.dto.translatedText, 'Olá');
    await reopened.close();
  });

  test('clear esvazia o cache', () async {
    final box = await Hive.openBox<Map>('cache_clear');
    final cache = HiveTranslationCacheDataSource(box);

    await cache.write(_key, _dto);
    await cache.clear();

    expect(await cache.read(_key), isNull);
    await box.close();
  });
}
