import 'package:flutter/material.dart';
import 'package:pinyinapp/app/theme/app_typography.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/shared/widgets/pinyin_text.dart';

String wordHeroTag(String namespace, String id) => 'hanzi-$namespace-$id';

class WordCard extends StatelessWidget {
  const WordCard({
    required this.word,
    required this.onTap,
    required this.heroNamespace,
    this.trailing,
    super.key,
  });

  final WordEntry word;
  final VoidCallback onTap;
  final String heroNamespace;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final definitions = word.definitions.take(2).map((d) => d.text).join('; ');

    return ListTile(
      onTap: onTap,
      leading: Hero(
        tag: wordHeroTag(heroNamespace, word.id),
        child: Material(
          type: MaterialType.transparency,
          child: Text(
            word.simplified,
            style: AppTypography.hanzi(
              context,
              size: AppTypography.hanziList,
            ),
          ),
        ),
      ),
      title: PinyinText(word.pinyin, size: AppTypography.pinyinList),
      subtitle: definitions.isEmpty
          ? null
          : Text(definitions, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing,
    );
  }
}
