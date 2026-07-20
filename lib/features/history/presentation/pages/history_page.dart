import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinyinapp/features/history/presentation/cubit/history_cubit.dart';
import 'package:pinyinapp/shared/widgets/empty_state.dart';
import 'package:pinyinapp/shared/widgets/failure_view.dart';
import 'package:pinyinapp/shared/widgets/word_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final cubit = context.read<HistoryCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
        actions: [
          IconButton(
            tooltip: 'Limpar histórico',
            onPressed: () => _confirmClear(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) => switch (state) {
          HistoryLoading() =>
            const Center(child: CircularProgressIndicator.adaptive()),
          HistoryError(:final failure) => FailureView(failure: failure),
          HistoryLoaded(:final items) when items.isEmpty => const EmptyState(
              icon: Icons.history,
              title: 'Sem consultas ainda',
              message: 'As palavras que você abrir aparecem aqui.',
            ),
          HistoryLoaded(:final items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final entry = items[index];
                return WordCard(
                  word: entry.word,
                  onTap: () => context.push('/word/${entry.word.id}'),
                  trailing: entry.visitCount > 1
                      ? Text('${entry.visitCount}×')
                      : null,
                );
              },
            ),
        },
      ),
    );
  }
}
