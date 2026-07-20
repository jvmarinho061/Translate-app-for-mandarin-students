import 'package:flutter/material.dart';
import 'package:pinyinapp/app/theme/tone_colors.dart';

abstract final class AppTheme {
  static const Color _seed = Color(0xFFB3261E);

  static ThemeData light() => _build(Brightness.light, ToneColors.light);

  static ThemeData dark() => _build(Brightness.dark, ToneColors.dark);

  static ThemeData _build(Brightness brightness, ToneColors tones) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      extensions: [tones],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
