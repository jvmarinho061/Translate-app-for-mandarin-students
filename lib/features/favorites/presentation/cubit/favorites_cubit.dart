import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/favorites/domain/entities/favorite_word.dart';
import 'package:pinyinapp/features/favorites/domain/repositories/favorites_repository.dart';

sealed class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded(this.items);
  final List<FavoriteWord> items;
  @override
  List<Object?> get props => [items];
}

class FavoritesError extends FavoritesState {
  const FavoritesError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this.repository) : super(const FavoritesLoading()) {
    _subscription = repository.watchAll().listen(
          (result) => emit(
            result.fold(
              onSuccess: FavoritesLoaded.new,
              onFailure: FavoritesError.new,
            ),
          ),
        );
  }

  final FavoritesRepository repository;
  late final StreamSubscription<void> _subscription;

  Future<void> add(WordEntry word) => repository.add(word);

  Future<void> remove(String wordId) => repository.remove(wordId);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}

class IsFavoriteCubit extends Cubit<bool> {
  IsFavoriteCubit(this.repository, this.wordId) : super(false) {
    _subscription = repository
        .watchIsFavorite(wordId)
        .listen((result) => emit(result.valueOrNull ?? false));
  }

  final FavoritesRepository repository;
  final String wordId;
  late final StreamSubscription<void> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
