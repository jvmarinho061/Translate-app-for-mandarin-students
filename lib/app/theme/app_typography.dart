import 'package:flutter/material.dart';
abstract final class AppTypography {
  static const String cjkFamily = 'NotoSansSC';
  static const double hanziDetail = 88;
  static const double hanziList = 30;
  static const double pinyinDetail = 22;
  static const double pinyinList = 15;

  static TextStyle hanzi(BuildContext context, {required double size}) =>
      TextStyle(
        fontFamily: cjkFamily,
        fontSize: size,
        height: 1.2,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle pinyin({required double size, Color? color}) => TextStyle(
        fontFamily: cjkFamily,
        fontSize: size,
        height: 1.3,
        letterSpacing: 0.3,
        color: color,
      );
}
