import 'dart:async';

import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/core/result/result.dart';

extension ResultStreamX<T> on Stream<T> {
  Stream<Result<R>> toResult<R>({
    required R Function(T value) onData,
    required Failure Function(Object error) onError,
  }) =>
      transform(
        StreamTransformer<T, Result<R>>.fromHandlers(
          handleData: (value, sink) => sink.add(Success(onData(value))),
          handleError: (error, _, sink) =>
              sink.add(FailureResult(onError(error))),
        ),
      );
}
