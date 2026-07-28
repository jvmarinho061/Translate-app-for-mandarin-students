import 'package:hive_ce/hive.dart';
import 'package:pinyinapp/core/error/exceptions.dart';

abstract interface class SettingsLocalDataSource {
  String? readThemeMode();

  Future<void> writeThemeMode(String mode);
}

class HiveSettingsLocalDataSource implements SettingsLocalDataSource {
  const HiveSettingsLocalDataSource(this.box);

  final Box<Map> box;

  static const String _key = 'theme';
  static const int schemaVersion = 1;

  @override
  String? readThemeMode() => box.get(_key)?['mode'] as String?;

  @override
  Future<void> writeThemeMode(String mode) async {
    try {
      await box.put(_key, {'schemaVersion': schemaVersion, 'mode': mode});
    } on Object catch (error) {
      throw CacheException('Falha ao salvar a preferência de tema.',
          cause: error);
    }
  }
}
