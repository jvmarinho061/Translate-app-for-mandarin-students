import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/app/theme/app_typography.dart';
import 'package:pinyinapp/core/di/dependencies.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/audio/presentation/cubit/audio_cubit.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';
import 'package:pinyinapp/features/translation/presentation/cubit/translation_cubit.dart';
import 'package:pinyinapp/shared/widgets/failure_view.dart';
import 'package:pinyinapp/shared/widgets/pinyin_text.dart';

class WordDetailPage extends StatefulWidget {
  const WordDetailPage({
    required this.wordId,
    required this.dependencies,
    super.key,
  });

  final String wordId;
  final Dependencies dependencies;

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  WordEntry? _word;
  Object? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.dependencies.dictionary.getById(widget.wordId);
    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        setState(() => _word = value);
        await widget.dependencies.history.record(value);
      case FailureResult(:final failure):
        setState(() => _failure = failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;

    if (_failure != null) {
      return Scaffold(
        appBar: AppBar(),
        body: FailureView(failure: _failure! as dynamic),
      );
    }
    if (word == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AudioCubit(widget.dependencies.audio),
        ),
        BlocProvider(
          create: (_) => TranslationCubit(widget.dependencies.translation)
            ..translate(word.simplified, to: Language.portuguese),
        ),
        BlocProvider(
          create: (_) =>
              IsFavoriteCubit(widget.dependencies.favorites, word.id),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(actions: [_FavoriteButton(word: word)]),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Hero(
                tag: 'hanzi-${word.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    word.simplified,
                    style: AppTypography.hanzi(
                      context,
                      size: AppTypography.hanziDetail,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: PinyinText(
                word.pinyin,
                size: AppTypography.pinyinDetail,
              ),
            ),
            const SizedBox(height: 16),
            Center(child: _AudioButton(term: word.pronounceableTerm)),
            const SizedBox(height: 28),
            Text('Definições', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            for (final definition in word.definitions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('• ${definition.text}'),
              ),
            const SizedBox(height: 28),
            Text('Tradução', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            const _TranslationSection(),
          ],
        ),
      ),
    );
  }
}

class _AudioButton extends StatelessWidget {
  const _AudioButton({required this.term});

  final String term;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        final icon = switch (state) {
          AudioBuffering() => Icons.hourglass_empty,
          AudioError() => Icons.volume_off,
          _ => Icons.volume_up,
        };

        return FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
          onPressed: () => context.read<AudioCubit>().play(term),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(icon, key: ValueKey(icon)),
          ),
          label: const Text('Ouvir'),
        );
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.word});

  final WordEntry word;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IsFavoriteCubit, bool>(
      builder: (context, isFavorite) {
        final favorites = context.read<IsFavoriteCubit>().repository;
        return IconButton(
          tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
          onPressed: () => isFavorite
              ? favorites.remove(word.id)
              : favorites.add(word),
          icon: AnimatedScale(
            scale: isFavorite ? 1.15 : 1,
            duration: const Duration(milliseconds: 200),
            child: Icon(isFavorite ? Icons.star : Icons.star_border),
          ),
        );
      },
    );
  }
}

/// Isolada em seu próprio bloco: uma falha de tradução não pode apagar da tela
class _TranslationSection extends StatelessWidget {
  const _TranslationSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationCubit, TranslationState>(
      builder: (context, state) => switch (state) {
        TranslationIdle() => const SizedBox.shrink(),
        TranslationLoading() => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        TranslationLoaded(:final translation) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(translation.translatedText)),
              if (translation.isStale)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Tooltip(
                    message: 'Tradução possivelmente desatualizada',
                    child: Icon(Icons.cloud_off, size: 18),
                  ),
                ),
            ],
          ),
        TranslationError(:final failure) => Text(
            FailureMessageMapper.message(failure),
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
      },
    );
  }
}
