import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/settings/domain/entities/app_theme_mode.dart';

abstract interface class SettingsRepository {
  Result<AppThemeMode> readThemeMode();

  Future<Result<void>> saveThemeMode(AppThemeMode mode);
}
