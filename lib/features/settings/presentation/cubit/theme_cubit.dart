import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/features/settings/domain/entities/app_theme_mode.dart';
import 'package:pinyinapp/features/settings/domain/repositories/settings_repository.dart';

class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit(this.repository)
      : super(
          repository.readThemeMode().valueOrNull ?? AppThemeMode.system,
        );

  final SettingsRepository repository;

  Future<void> select(AppThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await repository.saveThemeMode(mode);
  }
}
