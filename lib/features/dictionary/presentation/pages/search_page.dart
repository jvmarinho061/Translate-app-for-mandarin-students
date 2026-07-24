import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinyinapp/features/dictionary/presentation/cubit/search_cubit.dart';
import 'package:pinyinapp/features/history/presentation/cubit/history_cubit.dart';
import 'package:pinyinapp/shared/widgets/empty_state.dart';
import 'package:pinyinapp/shared/widgets/failure_view.dart';
import 'package:pinyinapp/shared/widgets/word_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitExample(String example) {
    _controller.text = example;
    context.read<SearchCubit>().queryChanged(example);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Buscar 汉字 ou pinyin',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: context.read<SearchCubit>().queryChanged,
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) => switch (state) {
          SearchIdle() => _RecentHistory(onExampleTap: _submitExample),
          SearchLoading() =>
            const Center(child: CircularProgressIndicator.adaptive()),
          SearchLoaded(:final results) => ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final word = results[index];
                return WordCard(
                  word: word,
                  heroNamespace: 'search',
                  onTap: () => context.push('/word/${word.id}?from=search'),
                );
              },
            ),
          SearchEmpty(:final query) => EmptyState(
              icon: Icons.search_off,
              title: 'Nada encontrado para "$query"',
              message: 'Tente o hanzi ou o pinyin sem tom.',
            ),
          SearchError(:final failure) => FailureView(failure: failure),
        },
      ),
    );
  }
}

class _RecentHistory extends StatelessWidget {
  const _RecentHistory({required this.onExampleTap});

  final ValueChanged<String> onExampleTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        if (state is! HistoryLoaded || state.items.isEmpty) {
          return EmptyState(
            icon: Icons.translate,
            title: 'Busque uma palavra',
            message: 'Você pode digitar em chinês ou em pinyin.',
            examples: const ['你好', 'ni hao'],
            onExampleTap: onExampleTap,
          );
        }

        final recent = state.items.take(20).toList();
        return ListView.builder(
          itemCount: recent.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Recentes',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              );
            }
            final entry = recent[index - 1];
            return WordCard(
              word: entry.word,
              heroNamespace: 'search',
              onTap: () => context.push('/word/${entry.word.id}?from=search'),
            );
          },
        );
      },
    );
  }
}
