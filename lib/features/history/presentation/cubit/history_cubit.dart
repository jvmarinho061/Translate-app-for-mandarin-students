import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/features/history/domain/entities/history_entry.dart';
import 'package:pinyinapp/features/history/domain/repositories/history_repository.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded(this.items);
  final List<HistoryEntry> items;
  @override
  List<Object?> get props => [items];
}

class HistoryError extends HistoryState {
  const HistoryError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this.repository) : super(const HistoryLoading()) {
    _subscription = repository.watchAll().listen(
          (result) => emit(
            result.fold(
              onSuccess: HistoryLoaded.new,
              onFailure: HistoryError.new,
            ),
          ),
        );
  }

  final HistoryRepository repository;
  late final StreamSubscription<void> _subscription;

  Future<void> remove(String wordId) => repository.remove(wordId);

  Future<void> clear() => repository.clear();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
