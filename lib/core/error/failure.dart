import 'package:equatable/equatable.dart';

/// Falha **de domínio**: descreve o que deu errado em termos que a regra de
/// negócio e a UI entendem, sem vazar detalhe de infraestrutura (status HTTP,
/// código do fornecedor, SQL).
///
/// Hierarquia `sealed` para permitir `switch` exaustivo no mapeamento
/// falha -> mensagem localizada.
sealed class Failure extends Equatable {
  const Failure({this.debugMessage});

  /// Detalhe técnico para log. **Não** deve ser exibido ao usuário.
  final String? debugMessage;

  @override
  List<Object?> get props => [runtimeType, debugMessage];
}

/// Falha de transporte: DNS, timeout, conexão recusada.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.debugMessage});
}

/// Sem conectividade e sem dado local utilizável.
final class OfflineFailure extends Failure {
  const OfflineFailure({super.debugMessage});
}

/// Cota/limite de requisições do fornecedor excedido.
final class ApiQuotaFailure extends Failure {
  const ApiQuotaFailure({super.debugMessage});
}

/// Credenciais ausentes, inválidas ou assinatura recusada.
final class ApiAuthFailure extends Failure {
  const ApiAuthFailure({super.debugMessage});
}

/// O fornecedor respondeu, mas de forma que não conseguimos interpretar.
final class ApiContractFailure extends Failure {
  const ApiContractFailure({super.debugMessage});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.debugMessage});
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure({super.debugMessage});
}

final class AudioFailure extends Failure {
  const AudioFailure({super.debugMessage});
}

/// Entrada inválida detectada antes de gastar rede ou disco.
final class ValidationFailure extends Failure {
  const ValidationFailure({this.reason, super.debugMessage});

  final String? reason;

  @override
  List<Object?> get props => [...super.props, reason];
}

/// Rede indisponível para funcionalidade não suportada na plataforma atual.
final class UnsupportedPlatformFailure extends Failure {
  const UnsupportedPlatformFailure({super.debugMessage});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.debugMessage});
}
