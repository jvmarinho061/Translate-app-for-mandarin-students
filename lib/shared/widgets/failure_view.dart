import 'package:flutter/material.dart';
import 'package:pinyinapp/core/error/failure.dart';

abstract final class FailureMessageMapper {
  static String message(Failure failure) => switch (failure) {
        OfflineFailure() =>
          'Sem conexão. O dicionário continua disponível offline.',
        NetworkFailure() => 'Falha de rede. Tente novamente.',
        ApiQuotaFailure() => 'Limite de traduções atingido por agora.',
        ApiAuthFailure() => 'Credenciais de tradução inválidas.',
        ApiContractFailure() => 'Resposta inesperada do serviço de tradução.',
        NotFoundFailure() => 'Termo não encontrado.',
        DatabaseFailure() => 'Falha ao acessar os dados locais.',
        AudioFailure() => 'Não foi possível reproduzir a pronúncia.',
        ValidationFailure(:final reason) => reason ?? 'Entrada inválida.',
        UnsupportedPlatformFailure() =>
          'Recurso indisponível nesta plataforma.',
        UnexpectedFailure() => 'Algo deu errado.',
      };
}

class FailureView extends StatelessWidget {
  const FailureView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              failure is OfflineFailure ? Icons.cloud_off : Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              FailureMessageMapper.message(failure),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
            ],
          ],
        ),
      ),
    );
  }
}
