sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() =>
      cause == null ? '$runtimeType: $message' : '$runtimeType: $message ($cause)';
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

/// Erro sinalizado pelo fornecedor remoto que não se encaixa nas categorias
/// específicas (auth, cota, contrato); [code] preserva o código original.
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
