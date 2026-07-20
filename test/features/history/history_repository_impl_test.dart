import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/definition.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/history/data/datasources/history_local_data_source.dart';
import 'package:pinyinapp/features/history/data/repositories/history_repository_impl.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';

WordEntry _word(String id) => WordEntry(
      id: id,
      simplified: 'w$id',
      pinyin: const Pinyin(marked: 'a', numbered: 'a1', toneless: 'a'),
      definitions: const [
        Definition(text: 'def', language: Language.english),
      ],
    );

void main() {
  late Directory tempDir;
  late Box<Map> box;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('history_test');
    Hive.init(tempDir.path);
    box = await Hive.openBox<Map>('history_test');
  });

  tearDown(() async {
    await box.close();
    await tempDir.delete(recursive: true);
  });

  HistoryRepositoryImpl build({int maxEntries = 500}) => HistoryRepositoryImpl(
        dataSource: HiveHistoryLocalDataSource(box),
        maxEntries: maxEntries,
      );

  test('registra uma consulta', () async {
    final repository = build();
    await repository.record(_word('1'));

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all, hasLength(1));
    expect(all.first.visitCount, 1);
  });

  test('revisita deduplica e incrementa visitCount', () async {
    final repository = build();
    await repository.record(_word('1'));
    await repository.record(_word('1'));
    await repository.record(_word('1'));

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all, hasLength(1));
    expect(all.first.visitCount, 3);
  });

  test('mais recentes primeiro', () async {
    final repository = build();
    await repository.record(_word('1'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repository.record(_word('2'));

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all.map((e) => e.word.id), ['2', '1']);
  });

  test('revisitar um termo antigo o traz de volta ao topo', () async {
    final repository = build();
    await repository.record(_word('1'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repository.record(_word('2'));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repository.record(_word('1'));

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all.map((e) => e.word.id), ['1', '2']);
  });

  test('aplica o teto de retenção descartando os mais antigos', () async {
    final repository = build(maxEntries: 3);
    for (var i = 1; i <= 5; i++) {
      await repository.record(_word('$i'));
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }

    final all = (await repository.watchAll().first).valueOrNull!;
    expect(all, hasLength(3));
    expect(all.map((e) => e.word.id), ['5', '4', '3']);
  });

  test('limit restringe a leitura sem apagar dados', () async {
    final repository = build();
    for (var i = 1; i <= 4; i++) {
      await repository.record(_word('$i'));
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }

    expect((await repository.watchAll(limit: 2).first).valueOrNull, hasLength(2));
    expect((await repository.watchAll().first).valueOrNull, hasLength(4));
  });

  test('remove e clear', () async {
    final repository = build();
    await repository.record(_word('1'));
    await repository.record(_word('2'));

    await repository.remove('1');
    expect((await repository.watchAll().first).valueOrNull, hasLength(1));

    expect(await repository.clear(), isA<Success<void>>());
    expect((await repository.watchAll().first).valueOrNull, isEmpty);
  });
}
