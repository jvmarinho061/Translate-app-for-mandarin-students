/// Exceções **técnicas**, lançadas exclusivamente por data sources e providers.
///
/// Elas nunca atravessam a fronteira do repositório: é responsabilidade do
/// `*RepositoryImpl` capturá-las e convertê-las em `Failure` de domínio. Manter
/// essa conversão em um único ponto por repositório evita que detalhes de HTTP
/// ou SQL se espalhem pelo resto do app.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

/// Falha de transporte antes de obter resposta útil.
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

/// O fornecedor respondeu com erro de negócio próprio.
///
/// Importante: a Baidu sinaliza erro **com HTTP 200 e `error_code` no corpo**,
/// por isso essa exceção não deriva de status HTTP.
final class RemoteApiException extends AppException {
  const RemoteApiException(super.message, {this.code, super.cause});

  final String? code;
}

final class ApiAuthException extends AppException {
  const ApiAuthException(super.message, {super.cause});
}

final class ApiQuotaException extends AppException {
  const ApiQuotaException(super.message, {super.cause});
}

/// Resposta fora do contrato esperado (campo ausente, tipo inesperado).
final class ApiContractException extends AppException {
  const ApiContractException(super.message, {super.cause});
}

final class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

final class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause});
}

final class AudioPlaybackException extends AppException {
  const AudioPlaybackException(super.message, {super.cause});
}
