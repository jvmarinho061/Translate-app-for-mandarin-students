import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinyinapp/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:pinyinapp/shared/widgets/empty_state.dart';
import 'package:pinyinapp/shared/widgets/failure_view.dart';
import 'package:pinyinapp/shared/widgets/word_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) => switch (state) {
          FavoritesLoading() =>
            const Center(child: CircularProgressIndicator.adaptive()),
          FavoritesError(:final failure) => FailureView(failure: failure),
          FavoritesLoaded(:final items) when items.isEmpty => const EmptyState(
              icon: Icons.star_border,
              title: 'Nenhum favorito ainda',
              message: 'Toque na estrela ao consultar uma palavra.',
            ),
          FavoritesLoaded(:final items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final favorite = items[index];
                return Dismissible(
                  key: ValueKey(favorite.word.id),
                  direction: DismissDirection.endToStart,
                  background: const ColoredBox(
                    color: Colors.transparent,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 24),
                        child: Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                  onDismissed: (_) =>
                      context.read<FavoritesCubit>().remove(favorite.word.id),
                  child: WordCard(
                    word: favorite.word,
                    onTap: () => context.push('/word/${favorite.word.id}'),
                  ),
                );
              },
            ),
        },
      ),
    );
  }
}
