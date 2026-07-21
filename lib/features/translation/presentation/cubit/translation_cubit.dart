import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinyinapp/core/error/failure.dart';
import 'package:pinyinapp/features/translation/domain/entities/language.dart';
import 'package:pinyinapp/features/translation/domain/entities/translation.dart';
import 'package:pinyinapp/features/translation/domain/repositories/translation_repository.dart';

sealed class TranslationState extends Equatable {
  const TranslationState();
  @override
  List<Object?> get props => [];
}

class TranslationIdle extends TranslationState {
  const TranslationIdle();
}

class TranslationLoading extends TranslationState {
  const TranslationLoading();
}

class TranslationLoaded extends TranslationState {
  const TranslationLoaded(this.translation);
  final Translation translation;
  @override
  List<Object?> get props => [translation];
}

class TranslationError extends TranslationState {
  const TranslationError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
class TranslationCubit extends Cubit<TranslationState> {
  TranslationCubit(this.repository) : super(const TranslationIdle());

  final TranslationRepository repository;

  Future<void> translate(String text, {required Language to}) async {
    emit(const TranslationLoading());
    final result = await repository.translate(
      text: text,
      from: Language.chinese,
      to: to,
    );
    if (isClosed) return;

    emit(
      result.fold(
        onSuccess: TranslationLoaded.new,
        onFailure: TranslationError.new,
      ),
    );
  }
}
