import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/features/dictionary/domain/entities/word_entry.dart';
import 'package:pinyinapp/features/dictionary/domain/repositories/dictionary_repository.dart';

sealed class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  const SearchLoaded(this.results);
  final List<WordEntry> results;
  @override
  List<Object?> get props => [results];
}

class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  const SearchError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this.repository) : super(const SearchIdle());

  final DictionaryRepository repository;

  Timer? _debounce;
  static const Duration debounceDuration = Duration(milliseconds: 150);

  void queryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(const SearchIdle());
      return;
    }

    _debounce = Timer(debounceDuration, () => search(trimmed));
  }

  Future<void> search(String query) async {
    emit(const SearchLoading());
    final result = await repository.search(query: query);
    if (isClosed) return;

    emit(
      result.fold(
        onSuccess: (results) =>
            results.isEmpty ? SearchEmpty(query) : SearchLoaded(results),
        onFailure: SearchError.new,
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
