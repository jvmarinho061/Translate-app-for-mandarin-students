import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/definition.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:pinyinapp/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

WordEntry _word(String id, String simplified) => WordEntry(
      id: id,
      simplified: simplified,
      pinyin: const Pinyin(
        marked: 'nǐ hǎo',
        numbered: 'ni3 hao3',
        toneless: 'ni hao',
      ),
      definitions: const [
        Definition(text: 'hello', language: Language.english),
      ],
    );

void main() {
  late Directory tempDir;
  late Box<Map> box;
  late FavoritesRepositoryImpl repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('favorites_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>('favorites_test');
    repository = FavoritesRepositoryImpl(
      dataSource: HiveFavoritesLocalDataSource(box),
    );
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  test('watchAll emite o estado ATUAL na primeira emissão', () async {
    await repository.add(_word('1', '你好'));

    // Se dependêssemos apenas de box.watch(), esta primeira emissão nunca
    // chegaria e a tela ficaria vazia.
    final first = await repository.watchAll().first;

    expect(first.valueOrNull, hasLength(1));
    expect(first.valueOrNull?.first.word.simplified, '你好');
  });

  test('watchAll reemite após add e após remove', () async {
    final emissions = <int>[];
    final subscription = repository.watchAll().listen(
          (result) => emissions.add(result.valueOrNull?.length ?? -1),
        );
    await pumpEventQueue();

    await repository.add(_word('1', '你好'));
    await pumpEventQueue();
    await repository.add(_word('2', '中国'));
    await pumpEventQueue();
    await repository.remove('1');
    await pumpEventQueue();

    // Precisa completar: um Bloc que trava ao fechar é bug de produção.
    await subscription.cancel();
    expect(emissions, [0, 1, 2, 1]);
  });

  test('add é idempotente e preserva a data original', () async {
    await repository.add(_word('1', '你好'));
    final first = (await repository.watchAll().first).valueOrNull!.first;

    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repository.add(_word('1', '你好'));

    final after = (await repository.watchAll().first).valueOrNull!;
    expect(after, hasLength(1));
    expect(after.first.createdAt, first.createdAt);
  });

  test('remove de item inexistente não é erro', () async {
    expect(await repository.remove('999'), isA<Success<void>>());
  });

  test('watchIsFavorite acompanha add e remove', () async {
    final states = <bool>[];
    final subscription = repository
        .watchIsFavorite('1')
        .listen((result) => states.add(result.valueOrNull ?? false));
    await pumpEventQueue();

    await repository.add(_word('1', '你好'));
    await pumpEventQueue();
    await repository.remove('1');
    await pumpEventQueue();

    // Precisa completar: um Bloc que trava ao fechar é bug de produção.
    await subscription.cancel();
    expect(states, [false, true, false]);
  });

  test('favoritos mais recentes vêm primeiro', () async {
    await repository.add(_word('1', '你好'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repository.add(_word('2', '中国'));

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all.map((f) => f.word.simplified), ['中国', '你好']);
  });
}
