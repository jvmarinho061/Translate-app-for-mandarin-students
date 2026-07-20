import 'package:flutter/material.dart';

@immutable
class ToneColors extends ThemeExtension<ToneColors> {
  const ToneColors({
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.neutral,
  });

  static const ToneColors light = ToneColors(
    first: Color(0xFFD32F2F),
    second: Color(0xFFE67E00),
    third: Color(0xFF2E7D32),
    fourth: Color(0xFF1565C0),
    neutral: Color(0xFF757575),
  );

  static const ToneColors dark = ToneColors(
    first: Color(0xFFFF8A80),
    second: Color(0xFFFFCC80),
    third: Color(0xFFA5D6A7),
    fourth: Color(0xFF90CAF9),
    neutral: Color(0xFFBDBDBD),
  );

  final Color first;
  final Color second;
  final Color third;
  final Color fourth;
  final Color neutral;

  Color forTone(int tone) => switch (tone) {
        1 => first,
        2 => second,
        3 => third,
        4 => fourth,
        _ => neutral,
      };

  @override
  ToneColors copyWith({
    Color? first,
    Color? second,
    Color? third,
    Color? fourth,
    Color? neutral,
  }) =>
      ToneColors(
        first: first ?? this.first,
        second: second ?? this.second,
        third: third ?? this.third,
        fourth: fourth ?? this.fourth,
        neutral: neutral ?? this.neutral,
      );

  @override
  ToneColors lerp(ToneColors? other, double t) {
    if (other == null) return this;
    return ToneColors(
      first: Color.lerp(first, other.first, t)!,
      second: Color.lerp(second, other.second, t)!,
      third: Color.lerp(third, other.third, t)!,
      fourth: Color.lerp(fourth, other.fourth, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}

extension ToneColorsContext on BuildContext {
  ToneColors get toneColors =>
      Theme.of(this).extension<ToneColors>() ?? ToneColors.light;
}
