import 'package:pinyinapp/core/error/failure.dart';

/// Transporta o desfecho de uma operação sem usar exceções como fluxo de controle.
///
/// É `sealed` para que `switch` sobre um [Result] seja exaustivo em tempo de
/// compilação: adicionar um novo caso quebra o build de quem não o tratou, em
/// vez de falhar silenciosamente em runtime.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        FailureResult<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        FailureResult<T>(:final failure) => failure,
      };

  /// Colapsa os dois ramos em um único valor. É o jeito preferido de consumir
  /// um [Result] na camada de apresentação.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final value) => onSuccess(value),
        FailureResult<T>(:final failure) => onFailure(failure),
      };

  /// Transforma o valor de sucesso preservando a falha.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Success<T>(:final value) => Success<R>(transform(value)),
        FailureResult<T>(:final failure) => FailureResult<R>(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;
}
