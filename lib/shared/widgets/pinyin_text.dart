import 'package:flutter/material.dart';
import 'package:pinyinapp/app/theme/app_typography.dart';
import 'package:pinyinapp/app/theme/tone_colors.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/pinyin.dart';

class PinyinText extends StatelessWidget {
  const PinyinText(this.pinyin, {required this.size, super.key});

  final Pinyin pinyin;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tones = context.toneColors;
    final markedSyllables = pinyin.marked.split(RegExp(r'\s+'))
      ..removeWhere((s) => s.isEmpty);
    final toneNumbers = _tonesOf(pinyin.numbered);

    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < markedSyllables.length; i++)
            TextSpan(
              text: i == markedSyllables.length - 1
                  ? markedSyllables[i]
                  : '${markedSyllables[i]} ',
              style: AppTypography.pinyin(
                size: size,
                color: tones.forTone(
                  i < toneNumbers.length ? toneNumbers[i] : 5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static List<int> _tonesOf(String numbered) => numbered
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .map((syllable) {
        final match = RegExp(r'[1-5]').firstMatch(syllable);
        return match == null ? 5 : int.parse(match.group(0)!);
      })
      .toList(growable: false);
}
