import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:pinyinapp/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:pinyinapp/features/settings/domain/entities/app_theme_mode.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('settings_test');
    Hive.init(tempDir.path);
  });

  tearDown(() async => tempDir.delete(recursive: true));

  SettingsRepositoryImpl repositoryFor(Box<Map> box) => SettingsRepositoryImpl(
        dataSource: HiveSettingsLocalDataSource(box),
      );

  test('box vazia devolve o padrão do sistema', () async {
    final box = await Hive.openBox<Map>('settings_empty');

    expect(repositoryFor(box).readThemeMode().valueOrNull, AppThemeMode.system);
    await box.close();
  });

  test('salva e relê a escolha', () async {
    final box = await Hive.openBox<Map>('settings_rw');
    final repository = repositoryFor(box);

    final saved = await repository.saveThemeMode(AppThemeMode.dark);

    expect(saved.isSuccess, isTrue);
    expect(repository.readThemeMode().valueOrNull, AppThemeMode.dark);
    await box.close();
  });

  test('valor irreconhecível na box decodifica para o sistema', () async {
    final box = await Hive.openBox<Map>('settings_corrupt');
    await box.put('theme', {'schemaVersion': 1, 'mode': 'sepia'});

    expect(repositoryFor(box).readThemeMode().valueOrNull, AppThemeMode.system);
    await box.close();
  });

  test('a escolha sobrevive ao fechamento e reabertura da box', () async {
    final box = await Hive.openBox<Map>('settings_persist');
    await repositoryFor(box).saveThemeMode(AppThemeMode.light);
    await box.close();

    final reopened = await Hive.openBox<Map>('settings_persist');

    expect(
      repositoryFor(reopened).readThemeMode().valueOrNull,
      AppThemeMode.light,
    );
    await reopened.close();
  });
}
