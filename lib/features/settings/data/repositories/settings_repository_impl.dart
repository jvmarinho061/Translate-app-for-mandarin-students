import 'package:pinyinapp/core/error/exceptions.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:pinyinapp/features/settings/domain/entities/app_theme_mode.dart';
import 'package:pinyinapp/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({required this.dataSource});

  final SettingsLocalDataSource dataSource;

  @override
  Result<AppThemeMode> readThemeMode() {
    try {
      return Success(AppThemeMode.fromName(dataSource.readThemeMode()));
    } on Object catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.toString()));
    }
  }

  @override
  Future<Result<void>> saveThemeMode(AppThemeMode mode) async {
    try {
      await dataSource.writeThemeMode(mode.name);
      return const Success(null);
    } on CacheException catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.message));
    } on Object catch (error) {
      return FailureResult(DatabaseFailure(debugMessage: error.toString()));
    }
  }
}
