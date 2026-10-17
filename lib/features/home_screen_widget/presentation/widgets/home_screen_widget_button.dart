import 'package:flutter/material.dart';
import 'package:pinyinapp/app/theme/app_typography.dart';
import 'package:pinyinapp/core/result/result.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/home_screen_widget/domain/entities/home_screen_widget_presence.dart';
import 'package:pinyinapp/features/home_screen_widget/domain/repositories/home_screen_widget_repository.dart';
import 'package:pinyinapp/shared/widgets/failure_view.dart';

class HomeScreenWidgetButton extends StatelessWidget {
  const HomeScreenWidgetButton({
    required this.repository,
    required this.word,
    super.key,
  });

  final HomeScreenWidgetRepository repository;
  final WordEntry word;

  Future<void> _show(BuildContext context) async {
    final result = await repository.show(word);
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Success(value: HomeScreenWidgetPresence.onHomeScreen):
        messenger.showSnackBar(
          SnackBar(content: Text('Widget atualizado: ${word.simplified}')),
        );
      case Success(value: HomeScreenWidgetPresence.pinRequested):
        // O diálogo de fixar do próprio launcher já é o retorno ao usuário.
        break;
      case Success(value: HomeScreenWidgetPresence.notAdded):
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (_) => _AddWidgetInstructions(word: word),
        );
      case FailureResult(:final failure):
        messenger.showSnackBar(
          SnackBar(content: Text(FailureMessageMapper.message(failure))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Mostrar no widget da tela inicial',
      onPressed: () => _show(context),
      icon: const Icon(Icons.widgets_outlined),
    );
  }
}

class _AddWidgetInstructions extends StatelessWidget {
  const _AddWidgetInstructions({required this.word});

  final WordEntry word;

  static const _iOSSteps = [
    'Na tela inicial, toque e segure um espaço vazio até os ícones tremerem.',
    'Toque no botão do canto superior esquerdo (Editar ou +) › Adicionar Widget.',
    'Procure por Pinyinapp, escolha o tamanho e toque em Adicionar Widget.',
  ];

  static const _androidSteps = [
    'Na tela inicial, toque e segure um espaço vazio.',
    'Toque em Widgets.',
    'Procure por pinyinapp, segure o widget Hanzi e arraste para a tela.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isIOS = theme.platform == TargetPlatform.iOS;
    final steps = isIOS ? _iOSSteps : _androidSteps;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                word.simplified,
                style: AppTypography.hanzi(context, size: 48),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione o widget à tela inicial',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              isIOS
                  ? 'O widget já vai mostrar esta palavra. O iOS só deixa você '
                      'mesmo colocá-lo na tela inicial, e isso só precisa ser '
                      'feito uma vez:'
                  : 'O widget já vai mostrar esta palavra. Seu launcher não '
                      'permite adicioná-lo pelo app, mas isso só precisa ser '
                      'feito uma vez:',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            for (final (index, step) in steps.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('${index + 1}. $step'),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
